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

    installMethod = lib.mkOption {
      type = lib.types.enum [ "hm" "sys" ];
      default = "hm";
      description = "Choose whether to install stremio via home-manager or directly in the environment.";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = lib.mkIf (cfg.installMethod == "hm") (with pkgs; [
      stremio
    ]);
  };
}
