{ pkgs, lib, config, ... }:

let
  cfg = config.modules.hm.extra.ignore-file-retriever;

  expandPath = path: let
    normalized = lib.removeSuffix "/" path;
  in if lib.hasPrefix "~/" normalized then
    config.home.homeDirectory + (lib.removePrefix "~/" normalized)
  else
    normalized;

  templatePath = expandPath cfg.templatePath;
  outputPath = expandPath cfg.outputPath;
  
  ignoreFileRetrieverScript = pkgs.writeShellScriptBin "ignore-file-retriever" ''
    #!/usr/bin/env bash
    set -euo pipefail

    TEMPLATE_FILE="''${TEMPLATE_FILE:-${templatePath}}"
    OUTPUT_FILE="''${OUTPUT_FILE:-${outputPath}}"
    WORKING_DIR="''${WORKING_DIR:-.}"

    # Verify template exists
    if [ ! -f "$TEMPLATE_FILE" ]; then
      echo "Error: Template file not found at $TEMPLATE_FILE" >&2
      exit 1
    fi

    # Create output directory if needed
    mkdir -p "$(dirname "$OUTPUT_FILE")"

    # Initialize output file with template if it doesn't exist
    if [ ! -f "$OUTPUT_FILE" ]; then
      cp "$TEMPLATE_FILE" "$OUTPUT_FILE"
      echo "Created $OUTPUT_FILE from template"
    fi

    # Create temporary file
    TMP_FILE="$(mktemp)"

    # Process all .gitignore files recursively
    find "$WORKING_DIR" -name ".gitignore" | while read -r gitignore; do
      echo "Processing $gitignore"
      
      # Get relative path from working directory
      rel_path="$(realpath --relative-to="$WORKING_DIR" "$(dirname "$gitignore")")"
      
      # Special case for root directory
      if [ "$rel_path" = "." ]; then
        rel_path=""
      else
        rel_path="$rel_path/"
      fi
      
      # Process each pattern
      while IFS= read -r pattern; do
        # Skip comments and empty lines
        [[ "$pattern" =~ ^#|^$ ]] && continue
        
        # Handle absolute paths
        if [[ "$pattern" =~ ^/ ]]; then
          echo "$pattern" >> "$TMP_FILE"
          continue
        fi
        
        # Handle directory patterns
        if [[ "$pattern" =~ /$ ]]; then
          echo "''${rel_path}''${pattern}" >> "$TMP_FILE"
        else
          # Handle normal patterns with proper directory prefix
          if [[ "$pattern" =~ / ]]; then
            # Pattern contains subdirectories
            echo "''${rel_path}''${pattern}" >> "$TMP_FILE"
          else
            # Simple pattern applies to all levels
            echo "**/''${pattern}" >> "$TMP_FILE"
          fi
        fi
      done < "$gitignore"
    done

    # Re-assemble final file: template + generated patterns
    cat "$TEMPLATE_FILE" > "$OUTPUT_FILE"
    cat "$TMP_FILE"      >> "$OUTPUT_FILE"
    rm "$TMP_FILE"
    echo "Updated $OUTPUT_FILE with patterns from .gitignore files"
  '';
in
{
  options.modules.hm.extra.ignore-file-retriever = {
    enable = lib.mkEnableOption "Enable ignore file retriever script to create .stignore from .gitignore patterns";

    templatePath = lib.mkOption {
      type = lib.types.str;
      default = "~/Templates/gitignore/.stignore.template";
      description = "Path to the template .stignore file";
    };

    outputPath = lib.mkOption {
      type = lib.types.str;
      default = "~/Templates/gitignore/.stignore";
      description = "Path to the output .stignore file";
    };

    watchMode = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether to watch for .gitignore changes and auto-update";
    };

    watchPaths = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
      description = "Additional paths to watch for .gitignore changes";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [
      ignoreFileRetrieverScript
      pkgs.inotify-tools
    ];

    home.file."${templatePath}".text = lib.mkIf (!lib.pathExists (expandPath cfg.templatePath)) ''
      # Syncthing ignore patterns
      # Generated from .gitignore files
      # (?!).*
      #
      # This file is automatically generated. Manual changes may be overwritten.
      # Add permanent custom patterns to the template file instead.
    '';

    systemd.user.services.ignore-file-watcher = lib.mkIf cfg.watchMode {
      Unit = {
        Description = "Watch for .gitignore changes and update .stignore";
        After = [ "network.target" ];
      };
      Service = {
        ExecStart = let
          watchDirs = lib.concatStringsSep " " (
            ["%h"] ++ map expandPath cfg.watchPaths
          );
        in
          "${pkgs.inotify-tools}/bin/inotifywait -m -r -e modify,move,create,delete \
            --format '%w%f' ${watchDirs} | \
            grep '\.gitignore$' | \
            while read -r path; do \
              WORKING_DIR=\"$(dirname \"$path\")\" ignore-file-retriever; \
            done";
        Restart = "always";
        RestartSec = "5s";
      };
      Install.WantedBy = [ "default.target" ];
    };
  };
}