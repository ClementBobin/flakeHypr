{
  inputs,
  lib,
  config,
  ...
}:

with lib;

let
  cfg = config.desktops.hydenix;

  configHydenix = import ./configHydenix.nix { inherit lib config; };

  # Validate hostnames
  validHostnames = [ "fern" "oak" "pine" "cedar" "sapling" "clover" ];
in
{

  imports = [
    ../common
    inputs.hydenix.homeModules.default
  ];

  options.desktops.hydenix = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = "Enable Hydenix desktop configuration";
    };

    hostname = mkOption {
      type = types.str;
      description = "Hostname for Hydenix desktop, used to determine userprefs.conf";
      example = "fern";
    };

    theme = {
      themes = mkOption {
        type = types.listOf types.str;
        default = [
          "Another World"
          "Cat Latte"
          "Catppuccin Latte"
          "Catppuccin Mocha"
          "Crimson Blade"
          "Ever Blushing"
          "Greenify"
          "One Dark"
          "Oxo Carbon"
          "Pixel Dream"
          "Rain Dark"
          "Rosé Pine"
          "Sci-fi"
          "Tokyo Night"
        ];
        description = "List of available themes for Hydenix desktop";
      };
    };

    randomOnBoot = {
      wallpaper = mkOption {
        type = types.bool;
        default = false;
        description = "Enable random wallpaper on boot";
      };

      theme = mkOption {
        type = types.bool;
        default = true;
        description = "Enable random theme on boot (requires random wallpaper to be enabled)";
      };
    };
  };

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = builtins.elem cfg.hostname validHostnames;
        message = "Hostname must be one of: ${toString validHostnames}. Got: ${cfg.hostname}";
      }
      {
        assertion = cfg.theme.themes != [];
        message = "Theme list cannot be empty";
      }
    ];

    hydenix.hm = {
      enable = true;
      dolphin.enable = cfg.enable;
      editors = {
        enable = cfg.enable;
        vscode.enable = false;
        neovim = false;
      };
      firefox.enable = cfg.enable;
      git = {
        enable = true;
        name = "mirage";
        email = "119869686+ClementBobin@users.noreply.github.com";
      };
      hyde.enable = cfg.enable;
      hyprland.enable = cfg.enable;
      lockscreen.enable = cfg.enable;
      notifications.enable = cfg.enable;
      qt.enable = cfg.enable;
      rofi.enable = cfg.enable;
      screenshots.enable = cfg.enable;
      social = {
        enable = cfg.enable;
        discord.enable = false;
        webcord.enable = false;
        vesktop.enable = cfg.enable;
      };
      spotify.enable = cfg.enable;
      swww.enable = cfg.enable;
      theme = {
        enable = cfg.enable;
        active = "Tokyo Night";
        themes = cfg.theme.themes;
      };
      waybar.enable = cfg.enable;
      wlogout.enable = cfg.enable;
      xdg.enable = cfg.enable;
    };

    home.file = {
      ".config/hypr/userprefs.conf" = lib.mkForce {
        text = ''
          input {
            kb_layout = fr
          }

          ${configHydenix.config}
          ${configHydenix.hyprlandKeybinds}

          # Example monitor configuration
          # Replace names like HDMI-A-1, DP-1, etc. with the actual names of your monitors (use `hyprctl monitors` to list)
          # monitor = <name>,<resolution@refresh>,<position>,<scale>,<features>,<enabled>
          # Features can include: "primary", "no-vrr", "no-hdr", "no-gamma", "vrr", etc.

          # Main display
          # monitor=HDMI-A-1,auto,0x0,1

          # Place DP-1 to the right of HDMI-A-1
          # monitor=DP-1,auto,1920x0,1

          # Place eDP-1 (e.g., laptop screen) above HDMI-A-1
          # monitor=eDP-1,auto,0x-1080,1

          # Place DP-2 below HDMI-A-1
          # monitor=DP-2,auto,0x1080,1

          # Place DP-3 diagonally bottom-right of HDMI-A-1
          # monitor=DP-3,auto,1920x1080,1

          # Disable an unused monitor (example)
          # monitor=DP-4,disable

          # Alt + Enter to toggle fullscreen
          bind = ALT, Return, fullscreen, 0

          # Alt + Tab to cycle between fullscreen windows
          bind = ALT, Tab, cyclenext
          bind = ALT, Tab, bringactivetotop

          bind = $mainMod Alt, G, exec, powermode-toggle.sh

          bind = $mainMod Alt, R, exec, random-theme.sh -all

          bind = $mainMod, M, exec, spotify
          bind = $mainMod, O, exec, obsidian

          ${configHydenix.exec-once}
        '';
        force = true;
        mutable = true;
      };
      ".local/bin/powermode-toggle.sh" = {
        source = ./powermode-toggle.sh;
        executable = true;
      };
      ".local/bin/nvidia-run" = {
        source = ./nvidia-run.sh;
        executable = true;
      };
      ".local/bin/random-theme.sh" = mkIf cfg.randomOnBoot.theme {
        source = ./random-theme.sh;
        executable = true;
      };
      # ".local/share/waybar/layouts/mirage.jsonc" = {
      #   source = ./mirage-waybar.jsonc;
      # };
    };
  };
}