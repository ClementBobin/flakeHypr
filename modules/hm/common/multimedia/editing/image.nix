{ pkgs, lib, config, ... }:

let
  cfg = config.modules.hm.multimedia.editing.image;
in
{
  options.modules.hm.multimedia.editing.image = {
    enable = lib.mkEnableOption "Enable image editor";
  };

  config = lib.mkIf cfg.enable {
    home.packages = (with pkgs; [
      krita
    ]);
  };
}
