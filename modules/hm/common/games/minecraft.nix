{ config, lib, pkgs, ... }:

let
  cfg = config.modules.common.games.minecraft;
in
{
  options.modules.common.games.minecraft = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable games minecraft";
    };

    installMethod = lib.mkOption {
      type = lib.types.enum [ "hm" "sys" ];
      default = "hm";
      description = "Choose whether to install games minecraft via home-manager or directly in the environment.";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = lib.mkIf (cfg.installMethod == "hm") (with pkgs; [
      prismlauncher
      jdk17
      gcc
      glibc
    ]);
  };
}
