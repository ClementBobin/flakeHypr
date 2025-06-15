{ config, lib, pkgs, ... }:

let
  cfg = config.modules.hm.games.minecraft;
in
{
  options.modules.hm.games.minecraft = {
    enable = lib.mkEnableOption "Enable Minecraft Launcher";
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
