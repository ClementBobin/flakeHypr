


{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.modules.common.utilities.kdeconnect;
in
{
  options.modules.common.utilities.kdeconnect = {
    enable = mkEnableOption "KDE Connect";
  };

  config = mkIf cfg.enable {
    services.kdeconnect.enable = true;
    services.kdeconnect.indicator = true;
  };
}