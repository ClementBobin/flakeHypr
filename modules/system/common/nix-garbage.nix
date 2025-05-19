{ lib, pkgs, inputs, config, ... }:

let
  cfg = config.modules.nix-garbage;
in
{
  options.modules.nix-garbage = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable Nix settings";
    };

    dates = lib.mkOption {
      type = lib.types.str;
      default = "weekly";
      description = "Schedule for automatic garbage collection";
    };

    optionDate = lib.mkOption {
      type = lib.types.str;
      default = "2d";
      description = "Garbage collection delete threshold (e.g. 2d, 1w)";
    };

    autoOptimiseStore = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether to enable automatic store optimization";
    };
  };

  config = lib.mkIf cfg.enable {
    nix = {
      settings = {
        auto-optimise-store = lib.mkForce cfg.autoOptimiseStore;
      };

      gc = {
        automatic = true;
        dates = cfg.dates;
        options = "--delete-older-than ${cfg.optionDate}";
      };
    };
  };
}
