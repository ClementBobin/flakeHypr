{
  inputs,
  lib,
  config,
  vars,
  ...
}:

with lib;

let
  cfg = config.desktops.hydenix;

  configHydenix = import ./configHydenix.nix { inherit lib config; };

  # Check if spicetify is in the clients list
  spicetifyEnabled = lib.elem "spicetify" config.modules.hm.multimedia.player.clients;

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
          "Tokyo Night"
          "Ever Blushing"
          "Pixel Dream"
          "Rain Dark"
          "Rosé Pine"
          "Timeless Dream"
          "Oregairu"
          "Obsidian-Purple"
          "Nier"
          "Green Lush"
        ];
          #"Greenify"
          #"Crimson Blade"
          #"One Dark"
          #"Oxo Carbon"
          #"Sci-fi"
          #"Vanta Black"
          #"Peace Of Mind"
        description = "List of available themes for Hydenix desktop";
      };
    };

    browser.enable = mkOption {
      type = types.bool;
      default = cfg.enable;
      description = "Enable Hydenix browser configuration";
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
      firefox.enable = cfg.browser.enable;
      git = {
        enable = cfg.enable;
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
        vesktop.enable = cfg.enable;
        webcord.enable = false;
      };
      spotify.enable = cfg.enable && !spicetifyEnabled;
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
            force_no_accel = true
            accel_profile = flat
            sensitivity = 0
          }

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

          bind = $mainMod Alt, G, exec, power-tools toggle

          bind = $mainMod Alt, R, exec, random-theme.sh -all

          bind = $mainMod, M, exec, spotify
          bind = $mainMod, O, exec, obsidian

          ${configHydenix.exec-once}
        '';
        force = true;
        mutable = true;
      };
      ".local/bin/nvidia-run" = {
        source = ./nvidia-run.sh;
        executable = true;
      };
      ".local/bin/random-theme.sh" = mkIf cfg.randomOnBoot.theme {
        source = ./random-theme.sh;
        executable = true;
      };
    };
    home.shellAliases = {
      fix-hypr-rules = "CHANGED=false; [ -s ~/.config/hypr/windowrules.conf ] && sudo mv ~/.config/hypr/windowrules.conf ~/.config/hypr/windowrules.conf.bak && sudo cp ~/.config/hypr/windowrules-hypr.conf ~/.config/hypr/windowrules.conf && CHANGED=true || echo 'First file empty, skipping'; [ -s ~/.local/share/hypr/windowrules.conf ] && sudo mv ~/.local/share/hypr/windowrules.conf ~/.local/share/hypr/windowrules.conf.bak && sudo cp ~/.local/share/hypr/windowrules-hypr.conf ~/.local/share/hypr/windowrules.conf && CHANGED=true || echo 'Second file empty, skipping'; if [ \"\$CHANGED\" = true ]; then echo 'Changes detected, reloading Hyprland...'; hyprctl reload; else echo 'No changes made.'; fi";
      rebuild-fix = "sudo rm /home/mirage/.local/share/hypr/windowrules.conf && sudo rm /home/mirage/.config/hypr/windowrules.conf";
      run-gittype = "nix run github:unhappychoice/gittype";
      run-gitlogue = "nix run github:unhappychoice/gitlogue";
      run-deadnix = "nix run github:astro/deadnix";
    };
  };
}