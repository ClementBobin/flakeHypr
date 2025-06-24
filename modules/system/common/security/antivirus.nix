{ config, lib, pkgs, ... }:

let
  cfg = config.modules.system.security.antivirus;

  # Map engines to their packages
  engineToPackages = {
    clamav = [ pkgs.clamav ] ++ lib.optionals cfg.gui.enable [ pkgs.clamtk ];
    sophos = [ pkgs.sophos-av ];
  };

  enabledEngines = lib.filter (e: e != "none") cfg.engines;

in {
  options.modules.system.security.antivirus = {
    gui.enable = lib.mkEnableOption "Enable GUI tools for the antivirus";
    engines = lib.mkOption {
      type = lib.types.listOf (lib.types.enum (lib.attrNames engineToPackages));
      default = [];
      description = "Select antivirus engines to install";
    };
  };

  config = {
    environment.systemPackages = lib.concatMap
      (engine: engineToPackages.${engine})
      enabledEngines;

    services.clamav = lib.mkIf (lib.elem "clamav" enabledEngines) {
      daemon.enable = true;
      updater.enable = true;
    };
  };
}