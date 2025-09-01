{ lib, pkgs, inputs, config, ... }:

let
  cfg = config.modules.system.nix.nix-garbage;
in
{
  options.modules.system.nix.nix-garbage = {
    enable = lib.mkEnableOption "Enable automatic garbage collection for Nix";

    autoGarbageCollection = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether to enable automatic garbage collection";
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
        auto-optimise-store = cfg.autoOptimiseStore;
      };

      gc = {
        automatic = lib.mkForce cfg.autoGarbageCollection;
        dates = cfg.dates;
        options = "--delete-older-than ${cfg.optionDate}";
      };
    };
  };
}
