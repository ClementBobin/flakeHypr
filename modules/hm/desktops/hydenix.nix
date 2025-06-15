{
  inputs,
  lib,
  config,
  ...
}:

with lib;

let
  cfg = config.desktops.hydenix;

  configHydenix = import ./configHydenix.nix { inherit lib; };
in
{

  imports = [
    ../common
    inputs.hydenix.lib.homeModules
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
  };

  config = mkIf cfg.enable {

    assertions = [
      {
        assertion = builtins.elem cfg.hostname [
          "fern" # Desktop
          "oak" # Laptop
          "pine" # Media
          "cedar" # Server
          "sapling" # Live USB OS
          "clover" # Main VM
        ];
        message = "Hostname must be one of: fern, oak, pine, cedar, sapling, clover";
      }
    ];

    hydenix.hm = {
      enable = true;
      gaming.enable = false;
      editors = {
        vscode.enable = false;
        neovim = false;
      };
      social = {
        webcord.enable = false;
        vesktop.enable = false;
      };
      git = {
        enable = true;
        name = "mirage";
        email = "119869686+ClementBobin@users.noreply.github.com";
      };
      theme = {
        active = "Tokyo Night";
        themes = [
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
      };
    };

    home.file = {
      ".config/hypr/userprefs.conf" = lib.mkForce {
        text = ''
          input {
            kb_layout = fr
          }

          ${configHydenix.hyprlandKeybindsConvert}

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

          exec-once = sleep 1 && keepassxc
        '';
        force = true;
        mutable = true;
      };
    };
  };
}
