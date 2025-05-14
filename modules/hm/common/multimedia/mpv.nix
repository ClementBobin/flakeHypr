{ pkgs, lib, config, ... }:

let
  cfg = config.modules.common.multimedia.mpv;
in
{
  options.modules.common.multimedia.mpv = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable mpv";
    };
  };

  config = lib.mkIf cfg.enable {
    # Configure mpv media player
      programs.mpv = {

        # Enable mpv
        enable = true;

        # Install custom scripts
        scripts = with pkgs; [
          mpvScripts.uosc
        ];

        # Script configuration
        scriptOpts."uosc" = {

          # Style of timeline
          "timeline_style" = "bar";

          # Volume to step when scrolling
          "volume_step" = 5;
        };
      };
  };
}
