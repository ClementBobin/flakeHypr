{ pkgs, lib, config, ... }:

let
  cfg = config.modules.common.multimedia.openshot-qt;
in
{
  options.modules.common.multimedia.openshot-qt = {
    enable = lib.mkEnableOption "Enable OpenShot video editor";
  };

  config = lib.mkIf cfg.enable {
    home.packages = (with pkgs; [
      openshot-qt
    ]);
  };
}
