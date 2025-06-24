{ pkgs, lib, config, ... }:

let
  cfg = config.modules.hm;

  # Map game engines to their packages
  engineToPackage = with pkgs; {
    unity = [ unityhub ];
  };

  # Get packages for enabled engines
  enginePackages = lib.concatMap (engine: engineToPackage.${engine} or []) cfg.engine;

in {
  options.modules.hm = {
    engine = lib.mkOption {
      type = lib.types.listOf (lib.types.enum (lib.attrNames engineToPackage));
      default = [];
      description = "List of game engines to install";
    };
  };

  config = {
    home.packages = enginePackages;
  };
}