{ pkgs, lib, config, ... }:

let
  cfg = config.modules.hm.games.mangohud;
in
{
 options.modules.hm.games.mangohud = {
    enable = lib.mkEnableOption "MangoHud - Vulkan/OpenGL overlay for performance monitoring and FPS counter";

    enableSessionWide = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = ''
          Enable MangoHud globally for all applications. When disabled,
          MangoHud must be launched per-application using the mangohud
          wrapper command (e.g., `mangohud game`).
      '';
    };

    fpsLimit = lib.mkOption {
      type = lib.types.ints.positive;
      default = 144;
      example = 120;
      description = "Global FPS limit applied when FPS limiting is enabled via hotkey";
    };

    position = lib.mkOption {
      type = lib.types.enum [ "top-left" "top-right" "bottom-left" "bottom-right" "top-center" "bottom-center" ];
      default = "top-left";
      description = "Screen position where the performance overlay will be displayed";
    };

    # CPU monitoring category
    cpu.text = lib.mkOption {
      type = lib.types.nullOr (lib.types.listOf lib.types.str);
      default = null;
      example = [ "AMD Ryzen 7 5800X" "AMD Rembrandt" ];
      description = ''
        Custom CPU identifier texts to display in the overlay, one per CPU.
        Leave as null for automatic detection based on your CPU models.
      '';
    };

    # GPU monitoring category
    gpu.text = lib.mkOption {
      type = lib.types.nullOr (lib.types.listOf lib.types.str);
      default = null;
      example = [ "NVIDIA RTX 4070" "AMD Radeon Integrated" ];
      description = ''
        Custom GPU identifier texts to display in the overlay, one per GPU.
        Leave as null for automatic detection based on your GPU models.
      '';
    };

    # Appearance category
    appearance = {
      backgroundAlpha = lib.mkOption {
        type = lib.types.float;
        default = 0.5;
        example = 0.7;
        description = "Transparency level of the overlay background (0.0 = fully transparent, 1.0 = fully opaque)";
      };

      fontSize = lib.mkOption {
        type = lib.types.ints.positive;
        default = 14;
        example = 16;
        description = "Font size in pixels for all overlay text elements";
      };

      textColor = lib.mkOption {
        type = lib.types.str;
        default = "ffffff";
        example = "00ff00";
        description = "Hexadecimal color code for text (without # prefix)";
      };
    };

    # Hotkeys category
    hotkeys = {
      toggleHud = lib.mkOption {
        type = lib.types.str;
        default = "Shift_L+F1";
        example = "F3";
        description = "Key combination to toggle the overlay visibility";
      };

      toggleFpsLimit = lib.mkOption {
        type = lib.types.str;
        default = "Shift_L+F2";
        example = "F4";
        description = "Key combination to toggle FPS limiting";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    home.file.".config/MangoHud/MangoHud.conf".enable = lib.mkForce false;

    # Enable mangohud
        programs.mangohud = {
          enable = true;
          enableSessionWide = cfg.enableSessionWide;

          # Configure general mangohud settings
          settings = let
            # Base settings without cpu_text and gpu_text
            baseSettings = {
              no_display = false;

              # Performance monitoring
              fps = true;
              fps_limit = cfg.fpsLimit;
              show_fps_limit = true;
              frame_timing = 1;
              frametime_color = "00ff00";
              throttling_status = true;
              gamemode = true;

              # CPU monitoring
              cpu_stats = true;
              cpu_temp = true;
              cpu_power = true;
              cpu_mhz = true;
              core_load = true;
              cpu_load_change = true;
              core_load_change = true;
              cpu_load_value = [ 50 90 ];
              cpu_load_color = [ "FFFFFF" "FFAA7F" "CC0000" ];
              cpu_color = "2e97cb";

              # GPU monitoring
              gpu_stats = true;
              gpu_temp = true;
              gpu_core_clock = true;
              gpu_mem_clock = true;
              gpu_power = true;
              gpu_load_change = true;
              gpu_load_value = [ 50 90 ];
              gpu_load_color = [ "FFFFFF" "FFAA7F" "CC0000" ];
              gpu_name = true;
              gpu_color = "2e9762";
              show_all_gpus = true;

              # Memory monitoring
              ram = true;
              ram_color = "c26693";
              vram = true;
              vram_color = "ad64c1";
              swap = true;
              io_stats = true;
              io_color = "a491d3";

              # System information
              engine_version = true;
              engine_color = "eb5b5b";
              vulkan_driver = true;
              wine = true;
              wine_color = "eb5b5b";
              time = true;

              # Overlay appearance
              legacy_layout = false;
              background_alpha = cfg.appearance.backgroundAlpha;
              background_color = "020202";
              position = cfg.position;
              text_color = cfg.appearance.textColor;
              round_corners = 10;
              font_size = cfg.appearance.fontSize;
              table_columns = 3;

              # Hotkeys
              toggle_hud = cfg.hotkeys.toggleHud;
              toggle_fps_limit = cfg.hotkeys.toggleFpsLimit;
              toggle_logging = "Shift_L+F4";
              upload_log = "Shift_L+F5";
              reload_cfg = "Super_L+Alt_L+R";

              # Logging
              output_folder = "$HOME/.mangologs";
              media_player_name = "spotify";
              media_player_color = "ffffff";
            };

            # Helper function to convert list to MangoHud's comma-separated format
            listToCsv = list: lib.concatStringsSep "," list;

            # Conditionally add cpu_text and gpu_text if they're not null
            optionalSettings = lib.optionalAttrs (cfg.cpu.text != null) {
              cpu_text = listToCsv cfg.cpu.text;
            } // lib.optionalAttrs (cfg.gpu.text != null) {
              gpu_text = listToCsv cfg.gpu.text;
            };
          in baseSettings // optionalSettings;

          # Configure mangohud settings per application
          settingsPerApplication = {
            # Disable mangohud for mpv
            mpv = {
              no_display = true;
            };
          };
        };
  };
}