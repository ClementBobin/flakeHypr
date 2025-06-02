{ pkgs, lib, config, ... }:

let
  cfg = config.modules.common.emulator.wine;
in
{
  options.modules.common.emulator.wine = {
    enable = lib.mkEnableOption "Enable Wine, a compatibility layer for running Windows applications on Linux";
  };

  config = lib.mkIf cfg.enable {
    home.packages = (with pkgs; [
      wine
      winetricks
    ]);
  };
}
