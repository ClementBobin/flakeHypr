{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.modules.common.utilities.kde-connect;
in
{
  options.modules.common.utilities.kde-connect = {
    enable = mkEnableOption "KDE Connect";
    indicator = mkOption {
      type = types.bool;
      default = true;
      description = "Enable the KDE Connect tray indicator.";
    };
  };

  config = mkIf cfg.enable {
    services.kdeconnect.enable = true;
    services.kdeconnect.indicator = cfg.indicator;
  };
}