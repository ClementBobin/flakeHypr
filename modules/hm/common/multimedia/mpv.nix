{ pkgs, lib, config, ... }:

let
  cfg = config.modules.hm.multimedia.mpv;
in
{
  options.modules.hm.multimedia.mpv = {
    enable = lib.mkEnableOption "Enable mpv media player with custom scripts";
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
