{ pkgs, lib, config, ... }:

let
  cfg = config.modules.hm.games.mangohud;
in
{
  options.modules.hm.games.mangohud = {
    enable = lib.mkEnableOption "Enable MangoHud, a Vulkan and OpenGL overlay layer for monitoring performance";
    cpu_text = lib.mkOption {
      type = lib.types.str;
      default = "";
      description = "Custom CPU text to display (leave empty for auto-detection)";
    };
    gpu_text = lib.mkOption {
      type = lib.types.str;
      default = "";
      description = "Custom GPU text to display (leave empty for auto-detection)";
    };
    enableSessionWide = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable mangohud session-wide";
    };
  };

  config = lib.mkIf cfg.enable {
    # Enable mangohud
        programs.mangohud = {
          enable = true;
          enableSessionWide = cfg.enableSessionWide;

          # Configure general mangohud settings
          settings = {
            fps_limit = 144;
            toggle_fps_limit = "Shift_L+F2";
            legacy_layout = false;

            gpu_stats = true;
            gpu_temp = true;
            gpu_core_clock = true;
            gpu_mem_clock = true;
            gpu_power = true;
            gpu_load_change = true;
            gpu_load_value = [ 50 90 ];
            gpu_load_color = [ "FFFFFF" "FFAA7F" "CC0000" ];

            cpu_stats = true;
            cpu_temp = true;
            core_load = true;
            cpu_power = true;
            cpu_mhz = true;
            cpu_load_change = true;
            core_load_change = true;
            cpu_load_value = [ 50 90 ];
            cpu_load_color = [ "FFFFFF" "FFAA7F" "CC0000" ];
            cpu_color = "2e97cb";
            cpu_text = if cfg.cpu_text != "" then cfg.cpu_text else null;

            io_color = "a491d3";
            swap = true;
            vram = true;
            vram_color = "ad64c1";
            ram = true;
            ram_color = "c26693";

            fps = true;
            engine_version = true;
            engine_color = "eb5b5b";

            gpu_name = true;
            gpu_text = if cfg.gpu_text != "" then cfg.gpu_text else "";
            gpu_color = "2e9762";

            vulkan_driver = true;
            wine = true;
            wine_color = "eb5b5b";

            frame_timing = 1;
            frametime_color = "00ff00";
            throttling_status = true;
            show_fps_limit = true;
            gamemode = true;

            time = true;
            table_columns = 3;

            background_alpha = 0.5;
            background_color = "020202";
            position = "top-left";
            text_color = "ffffff";
            round_corners = 10;

            font_size = 14;
            toggle_hud = "Shift_L+F1";
            toggle_logging = "Shift_L+F4";
            upload_log = "Shift_L+F5";
            reload_cfg = "Super_L+Alt_L+M";

            output_folder = "$HOME/.mangologs";
            media_player_name = "spotify";
            media_player_color = "ffffff";
          };

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
