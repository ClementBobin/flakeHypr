{ pkgs, lib, config, ... }:

let
  cfg = config.modules.hm.utilities.safety.ianny;
  
  # Import presets from JSON file
  presets = builtins.fromJSON (builtins.readFile ./config.json);

  # Function to generate TOML content with preset name comment
  generateToml = name: settings: ''
    # Ianny configuration
    # preset "${name}"
    
    [timer]
    # Enabling this will only consider user input alone for idle state, e.g. you will not have breaks when watching videos or playing music without any user input.
    ignore_idle_inhibitors = ${lib.boolToString settings.timer.ignoreIdleInhibitors}

    # Timer will stop and reset when you are idle for this amount of seconds.
    idle_timeout = ${toString settings.timer.idleTimeout}

    # Active duration that activates a break.
    short_break_timeout = ${toString settings.timer.shortBreakTimeout}
    long_break_timeout = ${toString settings.timer.longBreakTimeout}

    # Breaks duration.
    short_break_duration = ${toString settings.timer.shortBreakDuration}
    long_break_duration = ${toString settings.timer.longBreakDuration}

    [notification]
    show_progress_bar = ${lib.boolToString settings.notification.showProgressBar}
    # Minimum delay of updating the progress bar (lower than 1s may return an error).
    minimum_update_delay = ${toString settings.notification.minimumUpdateDelay}
  '';

  # Create preset files (respect cfg.presets)
  selectedPresets = lib.filterAttrs (name: _: lib.elem name cfg.presets) presets;
  presetFiles = lib.mapAttrs' (name: preset:
    lib.nameValuePair ".config/io.github.zefr0x.ianny/preset/${name}.toml" {
      text = generateToml name preset;
    }
  ) selectedPresets;

  # Custom configuration file content
  customConfig = generateToml "custom" cfg.settings;

  # Rofi-based selector script content with --game support
  selectorScriptContent = ''
    #!/usr/bin/env bash
    set -euo pipefail

    PRESET_DIR="$HOME/.config/io.github.zefr0x.ianny/preset"
    CONFIG_FILE="$HOME/.config/io.github.zefr0x.ianny/config.toml"
    GAME_PRESET="game"
    DEFAULT_PRESET="${cfg.defaultPreset or ""}"

    if [[ ! -d "$PRESET_DIR" ]]; then
      notify-send -a "Ianny" "No preset directory found at $PRESET_DIR"
      exit 1
    fi

    mapfile -t PRESETS < <(find "$PRESET_DIR" -maxdepth 1 -name "*.toml" -exec basename {} .toml \; | sort)

    if [[ ''${#PRESETS[@]} -eq 0 ]]; then
      notify-send -a "Ianny" "No presets available in $PRESET_DIR"
      exit 1
    fi

    if [[ "''${1:-}" == "--game" ]]; then
      if [[ ! " ''${PRESETS[*]} " =~ " $GAME_PRESET " ]]; then
        notify-send -a "Ianny" "Game preset not available"
        exit 1
      fi
      
      # Check current config by reading the preset name comment
      if [[ -f "$CONFIG_FILE" ]]; then
        current_preset=$(grep "^# preset \"" "$CONFIG_FILE" | head -1 | sed 's/^# preset "\(.*\)"$/\1/')
        if [[ "$current_preset" == "$GAME_PRESET" ]]; then
          current="$GAME_PRESET"
        else
          current="other"
        fi
      else
        current=""
      fi
      
      if [[ "$current" == "$GAME_PRESET" ]]; then
        # Toggle off: restore defaultPreset or show menu
        if [[ -n "$DEFAULT_PRESET" && -f "$PRESET_DIR/$DEFAULT_PRESET.toml" ]]; then
          cp "$PRESET_DIR/$DEFAULT_PRESET.toml" "$CONFIG_FILE"
          systemctl --user restart ianny
          notify-send -a "Ianny" "Preset '$DEFAULT_PRESET' restored"
        else
          # Show menu if no default
          exec "$0"
        fi
      else
        # Save current config as backup if not already game mode
        if [[ -f "$CONFIG_FILE" && "$current" != "$GAME_PRESET" ]]; then
          cp "$CONFIG_FILE" "$CONFIG_FILE.backup"
        fi
        cp "$PRESET_DIR/$GAME_PRESET.toml" "$CONFIG_FILE"
        systemctl --user restart ianny
        notify-send -a "Ianny" "Game preset activated"
      fi
      exit 0
    fi

    selected=$(
      printf '%s\n' "''${PRESETS[@]}" | rofi -dmenu -p "Select Ianny preset:"
    )

    if [[ -z "$selected" ]]; then
      exit 0
    fi

    if [[ "''${1:-}" == "--auto" ]]; then
      cp "$PRESET_DIR/$selected.toml" "$CONFIG_FILE"
      systemctl --user restart ianny
      notify-send -a "Ianny" "Preset '$selected' activated"
      exit 0
    fi

    confirm=$(printf "Yes\nNo" | rofi -dmenu -p "Activate '$selected'?")
    if [[ "$confirm" == "Yes" ]]; then
      cp "$PRESET_DIR/$selected.toml" "$CONFIG_FILE"
      systemctl --user restart ianny
      notify-send -a "Ianny" "Preset '$selected' activated"
    fi
  '';
in
{
  options.modules.hm.utilities.safety.ianny = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable Ianny break reminder";
    };

    mode = lib.mkOption {
      type = lib.types.enum [ "preset" "custom" ];
      default = "preset";
      description = ''
        Operation mode:
        - preset: Use predefined preset (can select multiple)
        - custom: Fully custom configuration
      '';
    };

    presets = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ "dev" ];
      description = "Which presets to make available";
    };

    defaultPreset = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Which preset to activate (null for custom)";
    };

    startAtLogin = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Start Ianny at login";
    };

    settings = {
      timer = {
        ignoreIdleInhibitors = lib.mkOption {
          type = lib.types.bool;
          default = false;
          description = "Only consider user input for idle state";
        };
        idleTimeout = lib.mkOption {
          type = lib.types.int;
          default = 240;
        };
        shortBreakTimeout = lib.mkOption {
          type = lib.types.int;
          default = 1200;
        };
        longBreakTimeout = lib.mkOption {
          type = lib.types.int;
          default = 3840;
        };
        shortBreakDuration = lib.mkOption {
          type = lib.types.int;
          default = 120;
        };
        longBreakDuration = lib.mkOption {
          type = lib.types.int;
          default = 240;
        };
      };
      notification = {
        showProgressBar = lib.mkOption {
          type = lib.types.bool;
          default = true;
        };
        minimumUpdateDelay = lib.mkOption {
          type = lib.types.int;
          default = 1;
        };
      };
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.mode != "preset" || cfg.presets != [];
        message = "ianny: when mode = \"preset\", at least one preset must be listed in ianny.presets.";
      }
      {
        assertion = cfg.defaultPreset == null || lib.elem cfg.defaultPreset cfg.presets;
        message = "ianny: defaultPreset must be one of ianny.presets (or null).";
      }
      {
        assertion = lib.all (p: lib.hasAttr p presets) cfg.presets;
        message = "ianny: every preset in ianny.presets must exist in config.json.";
      }
    ];

    home.packages = [
      pkgs.ianny
    ];

    home.file = lib.mkMerge [
      (lib.mkIf (cfg.mode == "custom") {
        ".config/io.github.zefr0x.ianny/config.toml".text = customConfig;
      })
      (lib.mkIf (cfg.mode == "preset") presetFiles)
      {
        ".local/bin/ianny-preset-selector" = {
          text = selectorScriptContent;
          executable = true;
        };
      }
    ];

    home.activation = lib.mkIf (cfg.mode == "preset" && cfg.defaultPreset != null) {
      iannySetup = lib.hm.dag.entryAfter ["writeBoundary"] ''
        if [[ -d "$HOME/.config/io.github.zefr0x.ianny/preset" ]]; then
          cp "$HOME/.config/io.github.zefr0x.ianny/preset/${cfg.defaultPreset}.toml" \
             "$HOME/.config/io.github.zefr0x.ianny/config.toml" || true
        fi
      '';
    };

    systemd.user.services.ianny = {
      Unit = {
        Description = "ianny - Safety net for Hydenix desktop";
        After = [ "graphical-session.target" ];
        PartOf = [ "graphical-session.target" ];
        ConditionPathExists = "%h/.config/io.github.zefr0x.ianny/config.toml";
      };
      Service = {
        ExecStart = "${pkgs.ianny}/bin/ianny";
        Restart = "always";
        RestartSec = 5;
      };
      Install = lib.mkIf cfg.startAtLogin {
        WantedBy = [ "graphical-session.target" ];
      };
    };
  };
}