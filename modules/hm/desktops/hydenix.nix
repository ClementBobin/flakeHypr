{
  inputs,
  lib,
  config,
  ...
}:

with lib;

let
  cfg = config.desktops.hydenix;
in
{

  imports = [
    inputs.hydenix.lib.homeModules
    ../common
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
      social = {
        webcord.enable = false;
        vesktop.enable = false;
      };
      editors.default = "nvim";
      git = {
        enable = true;
        name = "mirage";
        email = "clementbobin21@gmail.com";
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
        '';
        force = true;
        mutable = true;
      };
    };
  };
}
