{ config, lib, pkgs, ... }:

let
  cfg = config.modules.system.security.antivirus;

  # Map engines to their packages and service configs
  engineConfigs = {
    clamav = {
      packages = [ pkgs.clamav ] ++ lib.optionals cfg.gui.enable [ pkgs.clamtk ];
      services = {
        clamav = {
          daemon.enable = true;
          updater.enable = true;
        };
      };
    };
    sophos = {
      packages = [ pkgs.sophos-av ];
      services = {};
    };
    none = {
      packages = [];
      services = {};
    };
  };

  enabledEngines = lib.filter (e: e != "none") cfg.engines;

in {
  #### 🛠 Options
  options.modules.system.security.antivirus = {
    gui.enable = lib.mkEnableOption "Enable GUI tools for the antivirus";
    engines = lib.mkOption {
      type = lib.types.listOf (lib.types.enum (lib.attrNames engineConfigs));
      default = ["none"];
      description = "Select antivirus engines to install";
    };
  };

  #### ⚙ Configuration
  config = lib.mkMerge [
    {
      environment.systemPackages = lib.concatMap
        (engine: engineConfigs.${engine}.packages)
        enabledEngines;
    }
    (lib.mkIf (lib.elem "clamav" enabledEngines)
      engineConfigs.clamav.services
    )
  ];
}
