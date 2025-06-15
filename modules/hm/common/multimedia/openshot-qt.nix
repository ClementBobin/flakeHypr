{ pkgs, lib, config, ... }:

let
  cfg = config.modules.hm.multimedia.openshot-qt;
in
{
  options.modules.hm.multimedia.openshot-qt = {
    enable = lib.mkEnableOption "Enable OpenShot video editor";
  };

  config = lib.mkIf cfg.enable {
    home.packages = (with pkgs; [
      openshot-qt
    ]);
  };
}
