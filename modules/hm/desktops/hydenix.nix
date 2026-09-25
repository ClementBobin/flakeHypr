{
  inputs,
  lib,
  config,
  pkgs,
  vars,
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

    random = lib.mkOption {
      type = lib.types.enum [
        "none"
        "theme"
        "wallpaper"
        "all"
      ];
      default = "none";
      description = "Choose whether to apply a random theme, wallpaper, or both on activation.";
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
      editors.enable = false;
      browser.clients = ["zen"];
      spotify.clients = ["spicetify"];
      git = {
        enable = cfg.enable;
        name = "mirage";
        email = "119869686+ClementBobin@users.noreply.github.com";
      };
      hyde.enable = cfg.enable;
      hyprland = {
        enable = cfg.enable;
        extraConfig = configHydenix.hyprlandConfig;
      };
      management-utility.clients = ["nwg-displays"];
      lockscreen.enable = cfg.enable;
      notifications.enable = cfg.enable;
      qt.enable = cfg.enable;
      rofi.enable = cfg.enable;
      screenshots.enable = cfg.enable;
      social = {
        enable = cfg.enable;
        discord.enable = false;
        vesktop.enable = cfg.enable;
      };
      awww.enable = cfg.enable;
      theme = {
        enable = cfg.enable;
        active = "Tokyo Night";
        themes = cfg.theme.themes;
        random = cfg.random;
      };
      waybar.enable = cfg.enable;
      wlogout.enable = cfg.enable;
      xdg.enable = cfg.enable;
    };

    home = {
      file = {
        ".local/bin/nvidia-run" = {
          source = ./nvidia-run.sh;
          executable = true;
        };
      };
      shellAliases = {
        run-gittype = "nix run github:unhappychoice/gittype";
        run-gitlogue = "nix run github:unhappychoice/gitlogue";
        run-deadnix = "nix run github:astro/deadnix";
      };
    };
  };
}
