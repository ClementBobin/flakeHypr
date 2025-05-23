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
  };

  config = lib.mkIf cfg.enable {
    home.packages = (with pkgs; [
      prismlauncher
      jdk17
      gcc
      glibc
    ]);
  };
}
