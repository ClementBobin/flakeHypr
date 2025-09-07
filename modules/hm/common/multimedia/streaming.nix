{ pkgs, config, lib, ... }:

let
  cfg = config.modules.hm.multimedia.obs;
in
{
  options.modules.hm.multimedia.obs = {
    enable = lib.mkEnableOption "Enable OBS Studio for video recording and streaming";
  };

  config = lib.mkIf cfg.enable {
    home.packages = (with pkgs; [
      v4l-utils
    ]);

    programs.obs-studio = {
      enable = true;
      plugins = with pkgs.obs-studio-plugins; [
        wlrobs
        looking-glass-obs
        obs-pipewire-audio-capture
      ];
    };
  };
}
