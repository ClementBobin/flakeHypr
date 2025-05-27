{ pkgs, config, lib, ... }:

let
  cfg = config.modules.common.multimedia.obs;
in
{
  options.modules.common.multimedia.obs = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable obs";
    };
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
