{ pkgs, lib, config, ... }:

let
  cfg = config.modules.hm.multimedia.editing.video;
in
{
  options.modules.hm.multimedia.editing.video = {
    enable = lib.mkEnableOption "Enable OpenShot video editor";
  };

  config = lib.mkIf cfg.enable {
    home.packages = (with pkgs; [
      openshot-qt
    ]);
  };
}
