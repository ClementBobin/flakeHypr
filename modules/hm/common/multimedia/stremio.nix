{ pkgs, lib, config, ... }:

let
  cfg = config.modules.common.multimedia.stremio;
in
{
  options.modules.common.multimedia.stremio = {
    enable = lib.mkEnableOption "Enable Stremio media center";
  };

  config = lib.mkIf cfg.enable {
    home.packages = (with pkgs; [
      stremio
    ]);
  };
}
