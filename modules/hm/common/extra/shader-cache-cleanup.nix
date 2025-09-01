{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.modules.hm.extra.shader-cache-cleanup;

  # Default Steam library paths
  defaultSteamPaths = [
    "\${HOME}/.steam/steam"
    "\${HOME}/.local/share/Steam"
  ];

  # The script that handles the cleanup
  cleanupScript = pkgs.writeShellScriptBin "cleanup-shader-caches" ''
    set -euo pipefail

    # Help function
    show_help() {
      cat << EOF
    Usage: cleanup-shader-caches [OPTIONS]

    Clean up old Steam shader cache files to save disk space.

    Options:
      -h, --help          Show this help message and exit
      -d, --dry-run       Show what would be deleted without actually deleting
      -v, --verbose       Show detailed output
      -p, --paths PATHS   Override configured Steam paths (comma-separated)
      -t, --threshold N   Override configured days threshold
      --list-paths        Show detected Steam paths and exit
      --list-caches       Show detected shader cache directories and exit

    Examples:
      # Dry run to see what would be cleaned
      cleanup-shader-caches --dry-run

      # Clean with verbose output
      cleanup-shader-caches --verbose

      # Use custom paths and threshold
      cleanup-shader-caches --paths "~/.steam/root,~/.local/share/Steam" --threshold 30

    Configuration (from Nix module):
      Days Threshold: ${toString cfg.daysThreshold} days
      Steam Paths: ${toString cfg.steamPaths}
      File Patterns: ${toString cfg.filePatterns}
      Excluded Dirs: ${toString cfg.excludedDirs}
      Dry Run: ${if cfg.dryRun then "enabled" else "disabled"}
    EOF
    }

    # Parse command line arguments
    DRY_RUN=${if cfg.dryRun then "true" else "false"}
    VERBOSE=false
    CUSTOM_PATHS=""
    CUSTOM_THRESHOLD=""
    LIST_PATHS=false
    LIST_CACHES=false

    while [[ $# -gt 0 ]]; do
      case $1 in
        -h|--help)
          show_help
          exit 0
          ;;
        -d|--dry-run)
          DRY_RUN=true
          shift
          ;;
        -v|--verbose)
          VERBOSE=true
          shift
          ;;
        -p|--paths)
          CUSTOM_PATHS="$2"
          shift 2
          ;;
        -t|--threshold)
          CUSTOM_THRESHOLD="$2"
          shift 2
          ;;
        --list-paths)
          LIST_PATHS=true
          shift
          ;;
        --list-caches)
          LIST_CACHES=true
          shift
          ;;
        *)
          echo "Unknown option: $1"
          show_help
          exit 1
          ;;
      esac
    done

    # Use custom threshold if provided, otherwise use configured value
    DAYS_THRESHOLD=''${CUSTOM_THRESHOLD:-${toString cfg.daysThreshold}}

    # Use custom paths if provided, otherwise use configured paths
    if [ -n "$CUSTOM_PATHS" ]; then
      # Split comma-separated paths
      IFS=',' read -ra STEAM_PATHS <<< "$CUSTOM_PATHS"
    else
      STEAM_PATHS=(${toString cfg.steamPaths})
    fi

    # Find all potential Steam directories
    STEAM_DIRS=()
    for pattern in "''${STEAM_PATHS[@]}"; do
      # Expand ~ and environment variables
      expanded_dir=$(eval echo "$pattern")
      if [ -d "$expanded_dir" ]; then
        STEAM_DIRS+=("$expanded_dir")
        if [ "$VERBOSE" = true ] || [ "$LIST_PATHS" = true ]; then
          echo "Found Steam directory: $expanded_dir"
        fi
      elif [ "$VERBOSE" = true ]; then
        echo "Steam directory not found: $expanded_dir"
      fi
    done

    if [ ''${#STEAM_DIRS[@]} -eq 0 ]; then
      echo "No Steam directories found. Check your steamPaths configuration."
      exit 0
    fi

    if [ "$LIST_PATHS" = true ]; then
      echo "Detected Steam directories:"
      printf "  %s\n" "''${STEAM_DIRS[@]}"
      exit 0
    fi

    # Build find command for each directory
    FIND_CMD=()
    for steam_dir in "''${STEAM_DIRS[@]}"; do
      shader_cache_dir="$steam_dir/steamapps/shadercache"
      if [ -d "$shader_cache_dir" ]; then
        FIND_CMD+=("$shader_cache_dir")
        if [ "$VERBOSE" = true ] || [ "$LIST_CACHES" = true ]; then
          echo "Found shader cache directory: $shader_cache_dir"
        fi
      elif [ "$VERBOSE" = true ]; then
        echo "Shader cache directory not found: $shader_cache_dir"
      fi
    done

    if [ "$LIST_CACHES" = true ]; then
      echo "Detected shader cache directories:"
      printf "  %s\n" "''${FIND_CMD[@]}"
      exit 0
    fi

    if [ ''${#FIND_CMD[@]} -eq 0 ]; then
      echo "No shader cache directories found."
      exit 0
    fi

    if [ "$VERBOSE" = true ]; then
      echo "Cleaning shader caches in: ''${FIND_CMD[*]}"
      echo "Days threshold: $DAYS_THRESHOLD"
      echo "File patterns: ${toString cfg.filePatterns}"
      echo "Excluded directories: ${toString cfg.excludedDirs}"
      echo "Dry run: $DRY_RUN"
    fi

    # Build exclude patterns for find command
    EXCLUDE_CMD=""
    if [ ''${#cfg.excludedDirs[@]} -gt 0 ]; then
      for excluded_dir in ''${cfg.excludedDirs[@]}; do
        EXCLUDE_CMD+=" -not -path '*/$excluded_dir/*'"
      done
    fi

    # Build file pattern matching for find command
    PATTERN_CMD=""
    for pattern in ''${cfg.filePatterns[@]}; do
      if [ -z "$PATTERN_CMD" ]; then
        PATTERN_CMD="-name '$pattern'"
      else
        PATTERN_CMD="$PATTERN_CMD -o -name '$pattern'"
      fi
    done

    # Execute the cleanup
    if [ "$DRY_RUN" = true ]; then
      echo "=== DRY RUN - No files will be deleted ==="
      ACTION="-print"
    else
      ACTION="-delete"
    fi

    # Use eval to properly handle the complex find command
    eval "${pkgs.findutils}/bin/find \"''${FIND_CMD[@]}\" \
      -type f \
      \( $PATTERN_CMD \) \
      -mtime +$DAYS_THRESHOLD \
      $EXCLUDE_CMD \
      $ACTION"

    echo "Shader cache cleanup completed."
    if [ "$DRY_RUN" = true ]; then
      echo "This was a dry run. No files were actually deleted."
      echo "Run without --dry-run to perform the actual cleanup."
    fi
  '';

in {
  options.modules.hm.extra.shader-cache-cleanup = {
    enable = mkEnableOption "Automatic shader cache cleanup for Steam games";

    daysThreshold = mkOption {
      type = types.int;
      default = 90;
      description = "Delete shader cache files older than this many days";
    };

    interval = mkOption {
      type = types.str;
      default = "weekly";
      example = "daily";
      description = "How often to run the cleanup (systemd calendar format)";
    };

    steamPaths = mkOption {
      type = types.listOf types.str;
      default = defaultSteamPaths;
      description = "List of paths to Steam installations (supports environment variables)";
    };

    dryRun = mkOption {
      type = types.bool;
      default = false;
      description = "If enabled, only print files that would be deleted without actually deleting them";
    };

    user = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = "User whose shader caches to clean (defaults to current user if null)";
    };

    excludedDirs = mkOption {
      type = with types; listOf str;
      default = [];
      description = "List of directory names to exclude from cleanup";
      example = literalExpression ''
        ["108600"] # Skip cleaning Skyrim's shader cache
      '';
    };

    filePatterns = mkOption {
      type = with types; listOf str;
      default = ["*.vkd" "*.bin"];
      description = "File patterns to match for cleanup";
    };

    runAtStartup = mkEnableOption "Run cleanup at startup";

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
    home.packages = [ cleanupScript ];

    systemd.user = {
      services.shader-cache-cleanup = {
        Unit = {
          Description = "Clean up old Steam shader caches";
          After = [ "network.target" ];
        };

        Service = let
          cmd = "${cleanupScript}/bin/cleanup-shader-caches";
        in {
          ExecStart = cmd;
          Type = "oneshot";
          SuccessExitStatus = "0 1";
          ${if cfg.user != null then "User" else null} = mkIf (cfg.user != null) cfg.user;
        };
        Install = mkIf cfg.runAtStartup {
          WantedBy = [ "default.target" ];
        };
      };

      timers.shader-cache-cleanup = mkIf (cfg.timerConfig != {}) {
        Unit = {
          Description = "Timer for Steam shader cache cleanup";
        };
        Timer = cfg.timerConfig;
        Install = {
          WantedBy = [ "timers.target" ];
        };
      };
    };
  };
}