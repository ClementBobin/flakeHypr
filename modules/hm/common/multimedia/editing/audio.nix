{ pkgs, lib, config, ... }:

let
  cfg = config.modules.hm.multimedia.editing.audio;
in
{
  options.modules.hm.multimedia.editing.audio = {
    enable = lib.mkEnableOption "Enable audio editor";
  };

  config = lib.mkIf cfg.enable {
    home.packages = (with pkgs; [
      audacity
    ]);
  };
}
