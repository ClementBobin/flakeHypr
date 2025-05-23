{ pkgs, lib, config, ... }:

let
  cfg = config.modules.common.multimedia.stremio;
in
{
  options.modules.common.multimedia.stremio = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable stremio";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = (with pkgs; [
      stremio
    ]);
  };
}
