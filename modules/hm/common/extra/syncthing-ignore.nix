{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.modules.hm.extra.syncthing-ignore;

  # Build the find command with excluded paths
buildFindCommand = targetDir: excludedDirs:
  let
    excludePart = if excludedDirs == null || excludedDirs == [] then
      ""
    else
      " " + (concatMapStrings (dir: "-not -path '*/${dir}/*' ") excludedDirs);
  in
    ''${pkgs.findutils}/bin/find "$TARGET_DIR" -name ".gitignore" -type f -readable${excludePart} 2>/dev/null || true'';

  # The script that finds Syncthing folders from config.xml and aggregates .gitignore files
  ignoreAggregatorScript = pkgs.writeShellScriptBin "aggregate-ignores" ''
    #!/usr/bin/env bash
    set -euo pipefail

    # Function to expand character classes like [Ll] into multiple patterns
    expand_character_classes() {
      local pattern="$1"
      
      # Check if pattern contains simple character classes (not ranges like [0-9])
      if [[ "$pattern" =~ \[[^\]]+\] ]]; then
        # Find all simple character classes in the pattern
        local results=("$pattern")
        local changed=true
        
        while $changed; do
          changed=false
          local new_results=()
          
          for current_pattern in "''${results[@]}"; do
            # Look for the first simple character class (without number ranges)
            if [[ "$current_pattern" =~ (.*)\[([^0-9\-][^]]*)\](.*) ]]; then
              changed=true
              local before_class="''${BASH_REMATCH[1]}"
              local class_part="''${BASH_REMATCH[2]}"
              local after_class="''${BASH_REMATCH[3]}"
              
              # Only expand if it's not a numeric range pattern
              if [[ ! "$class_part" =~ [0-9]-[0-9] ]]; then
                # Generate all combinations for each character in this class
                for (( i=0; i<''${#class_part}; i++ )); do
                  local char="''${class_part:$i:1}"
                  new_results+=("''${before_class}''${char}''${after_class}")
                done
              else
                # It's a numeric range, don't expand
                new_results+=("$current_pattern")
              fi
            else
              # No more character classes to expand
              new_results+=("$current_pattern")
            fi
          done
          
          results=("''${new_results[@]}")
        done
        
        # Output each expanded pattern on a separate line
        printf "%s\n" "''${results[@]}"
      else
        # No character classes to expand, output as-is
        echo "$pattern"
      fi
    }

    # Function to extract folder paths from Syncthing config.xml
    extract_syncthing_folders() {
      local config_file="$1"
      if [[ ! -f "$config_file" ]]; then
        echo "Error: Syncthing config file not found: $config_file" >&2
        return 1
      fi

      # Use xmlstarlet to extract folder paths
      if command -v ${pkgs.xmlstarlet}/bin/xmlstarlet &> /dev/null; then
        ${pkgs.xmlstarlet}/bin/xmlstarlet sel -t -m "//folder" -v "@path" -n "$config_file" 2>/dev/null
      else
        # Fallback: use grep and sed (less reliable but works)
        grep -o 'path="[^"]*"' "$config_file" | sed 's/path="//;s/"$//'
      fi
    }

    function process_directory() {
      local TARGET_DIR="$1"
      local STIGNORE_FILE="$2"
      
      # Handle ~ expansion
      if [[ "$TARGET_DIR" == "~" ]]; then
        TARGET_DIR="$HOME"
      fi
      TARGET_DIR="''${TARGET_DIR/#\~/$HOME}"
      
      # Check if directory exists
      if [[ ! -d "$TARGET_DIR" ]]; then
        echo "Directory does not exist: $TARGET_DIR"
        return
      fi

      # Check if .stignore exists, if not create it
      if [[ ! -f "$STIGNORE_FILE" ]]; then
        echo "No .stignore file found in $TARGET_DIR, creating one."
        touch "$STIGNORE_FILE"
      fi

      echo "Processing directory: $TARGET_DIR"

      # Build the find command with excluded directories from config
      local FIND_CMD="${buildFindCommand "\$TARGET_DIR" cfg.excludedDirs}"

      # Find all .gitignore files automatically (no user interaction)
      local IGNORE_FILES=$(eval "$FIND_CMD")

      if [ -z "$IGNORE_FILES" ]; then
        echo "No .gitignore files found in $TARGET_DIR."
        return
      fi

      local found_count
      found_count=$(echo "$IGNORE_FILES" | ${pkgs.coreutils}/bin/wc -l)
      echo "Found $found_count .gitignore file(s) in $TARGET_DIR."

      echo "Aggregating to $STIGNORE_FILE..."
      echo "# Auto-generated from .gitignore files" > "$STIGNORE_FILE"
      echo "# Generated on $(date)" >> "$STIGNORE_FILE"
      echo "# Source directory: $TARGET_DIR" >> "$STIGNORE_FILE"
      echo >> "$STIGNORE_FILE"

      # Process each .gitignore file automatically
      while IFS= read -r gitignore; do
        local rel_path="''${gitignore#$TARGET_DIR/}"
        local dir_path="''${rel_path%/.gitignore}"

        echo "# =========================================" >> "$STIGNORE_FILE"
        echo "# From: $rel_path" >> "$STIGNORE_FILE"
        echo "# =========================================" >> "$STIGNORE_FILE"
        echo >> "$STIGNORE_FILE"

        # Add directory prefix only to non-empty, non-comment lines
        if [ "$dir_path" != ".gitignore" ]; then
          # Process each line, only add prefix to pattern lines (not comments or empty lines)
          while IFS= read -r line; do
            # Skip empty lines and comment lines
            if [[ -z "$line" || "$line" == \#* ]]; then
              echo "$line" >> "$STIGNORE_FILE"
            else
              # Expand character classes in the pattern
              expanded_patterns=$(expand_character_classes "$line")
              
              # Add directory prefix to each expanded pattern
              while IFS= read -r expanded_pattern; do
                if [[ -n "$expanded_pattern" ]]; then
                  echo "$dir_path/$expanded_pattern" >> "$STIGNORE_FILE"
                fi
              done <<< "$expanded_patterns"
            fi
          done < "$gitignore"
        else
          # For root .gitignore, expand character classes but don't add directory prefix
          while IFS= read -r line; do
            if [[ -z "$line" || "$line" == \#* ]]; then
              echo "$line" >> "$STIGNORE_FILE"
            else
              # Expand character classes in the pattern
              expanded_patterns=$(expand_character_classes "$line")
              
              # Add each expanded pattern
              while IFS= read -r expanded_pattern; do
                if [[ -n "$expanded_pattern" ]]; then
                  echo "$expanded_pattern" >> "$STIGNORE_FILE"
                fi
              done <<< "$expanded_patterns"
            fi
          done < "$gitignore"
        fi

        echo >> "$STIGNORE_FILE"
      done <<< "$IGNORE_FILES"

      echo "Done. $STIGNORE_FILE created/updated with content from $found_count .gitignore files."
    }

    MODE="$1"
    shift

    SYNCONFIG="${cfg.configXmlPath}"

    case "$MODE" in
      auto)
        # Extract folder paths from Syncthing config
        echo "Reading Syncthing folders from: $SYNCONFIG"
        FOLDER_PATHS=$(extract_syncthing_folders "$SYNCONFIG")
        
        if [ -z "$FOLDER_PATHS" ]; then
          echo "No Syncthing folders found in config.xml"
          exit 0
        fi
        
        echo "Found Syncthing folders:"
        echo "$FOLDER_PATHS"
        
        while IFS= read -r folder_path; do
          if [[ -n "$folder_path" && -d "$folder_path" ]]; then
            STIGNORE_FILE="$folder_path/.stignore"
            echo "Processing Syncthing folder: $folder_path"
            process_directory "$folder_path" "$STIGNORE_FILE"
          else
            echo "Skipping invalid or non-existent folder: $folder_path"
          fi
        done <<< "$FOLDER_PATHS"
        ;;
        
      manual)
        for TARGET_DIR in "$@"; do
          STIGNORE_FILE="$TARGET_DIR/.stignore"
          echo "Processing directory: $TARGET_DIR"
          process_directory "$TARGET_DIR" "$STIGNORE_FILE"
        done
        ;;
        
      *)
        echo "Usage: $0 auto|manual [directory...]"
        echo "  auto:    Process all folders from Syncthing config.xml"
        echo "  manual:  Process specified directories"
        exit 1
        ;;
    esac
  '';

in {
  options.modules.hm.extra.syncthing-ignore = {
    enable = mkEnableOption "Syncthing ignore file aggregator";

    mode = mkOption {
      type = types.enum ["auto" "manual"];
      default = "auto";
      description = ''
        Operation mode:
        - auto: find all Syncthing folders from config.xml and process them
        - manual: specify directories to process
      '';
    };

    configXmlPath = mkOption {
      type = types.str;
      default = "${config.home.homeDirectory}/.config/syncthing/config.xml";
      description = "Path to the Syncthing config.xml file";
    };

    targetDirs = mkOption {
      type = with types; listOf str;
      default = [];
      description = "Directories to process in manual mode";
    };

    excludedDirs = mkOption {
      type = with types; nullOr (listOf str);
      default = [];
      description = ''
        List of directory names to exclude from .gitignore search.
        These directories will be skipped when searching for .gitignore files.
        Set to null to disable all exclusions.
      '';
      example = literalExpression ''
        ["node_modules" "vendor" "dist" "build" ".cache"]
      '';
    };

    runAtStartup = mkEnableOption "Run aggregator at startup";

    timerConfig = mkOption {
      type = types.attrsOf types.str;
      default = {
        OnCalendar = "weekly";
        Persistent = "true";
      };
      description = "Systemd timer configuration for periodic runs";
    };
  };

  config = mkIf cfg.enable {
    home.packages = [ ignoreAggregatorScript pkgs.xmlstarlet ];

    systemd.user = {
      services.syncthing-ignore-aggregator = {
        Unit = {
          Description = "Aggregate .gitignore files for Syncthing folders";
          After = mkIf cfg.runAtStartup [ "default.target" ];
        };
        Service = let
          cmd = if cfg.mode == "auto" then
            "${ignoreAggregatorScript}/bin/aggregate-ignores auto"
          else
            "${ignoreAggregatorScript}/bin/aggregate-ignores manual ${toString cfg.targetDirs}";
        in {
          ExecStart = cmd;
          Type = "oneshot";
          SuccessExitStatus = "0 1";
        };
        Install = {
          WantedBy = [ "default.target" ];
        };
      };

      timers.syncthing-ignore-aggregator = mkIf (cfg.timerConfig != {}) {
        Unit = {
          Description = "Timer for Syncthing ignore file aggregator";
        };
        Timer = cfg.timerConfig;
        Install = {
          WantedBy = [ "timers.target" ];
        };
      };
    };
  };
}