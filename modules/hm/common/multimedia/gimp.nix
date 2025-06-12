{ pkgs, lib, config, ... }:

let
  cfg = config.modules.common.multimedia.gimp;
in
{
  options.modules.common.multimedia.gimp = {
    enable = lib.mkEnableOption "Enable GIMP image editor";
  };

  config = lib.mkIf cfg.enable {
    home.packages = (with pkgs; [
      gimp
    ]);
  };
}
