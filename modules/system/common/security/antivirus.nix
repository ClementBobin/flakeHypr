{ config, lib, pkgs, ... }:

let
  cfg = config.modules.security.antivirus;
in {
  #### 🛠 Options
  options.modules.security.antivirus = {
    enable = lib.mkEnableOption "Enable antivirus system-wide";

    gui.enable = lib.mkEnableOption "Enable GUI tools for the antivirus";

    engine = lib.mkOption {
      type = lib.types.enum [ "clamav" "none" ];
      default = "clamav";
      description = "Select the antivirus engine to install.";
    };
  };

  #### ⚙ Configuration
  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
    ] ++ lib.optionals (cfg.engine == "clamav") [
      clamav
    ] ++ lib.optionals (cfg.engine == "clamav" && cfg.gui.enable) [
      clamtk
    ];

    services = lib.mkIf (cfg.engine == "clamav") {
      clamav.daemon.enable   = true;
      clamav.updater.enable  = true;
    };
  };
}
