{ pkgs, lib, config, ... }:

let
  cfg = config.modules.hm.multimedia.gimp;
in
{
  options.modules.hm.multimedia.gimp = {
    enable = lib.mkEnableOption "Enable GIMP image editor";
  };

  config = lib.mkIf cfg.enable {
    home.packages = (with pkgs; [
      gimp
    ]);
  };
}
