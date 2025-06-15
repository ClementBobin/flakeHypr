{ pkgs, lib, config, ... }:

let
  cfg = config.modules.hm.multimedia.stremio;
in
{
  options.modules.hm.multimedia.stremio = {
    enable = lib.mkEnableOption "Enable Stremio media center";
  };

  config = lib.mkIf cfg.enable {
    home.packages = (with pkgs; [
      stremio
    ]);
  };
}
