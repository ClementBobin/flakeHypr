{ pkgs, config, lib, ... }:

let
  cfg = config.modules.hm.multimedia.streaming;
in
{
  options.modules.hm.multimedia.streaming = {
    obs.enable = lib.mkEnableOption "Enable OBS Studio for video recording and streaming";
    kooha.enable = lib.mkEnableOption "Enable Kooha for simple screen recording";
  };

  config = {
    home.packages = (with pkgs; []
      ++ (lib.optional cfg.kooha.enable kooha)
      ++ (lib.optional cfg.obs.enable v4l-utils)
    );

    programs.obs-studio = lib.mkIf cfg.obs.enable {
      enable = true;
      plugins = with pkgs.obs-studio-plugins; [
        wlrobs
        looking-glass-obs
        obs-pipewire-audio-capture
      ];
    };
  };
}
