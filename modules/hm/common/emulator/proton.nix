{ pkgs, lib, config, ... }:

let
  cfg = config.modules.common.emulator.proton;
in
{
  options.modules.common.emulator.proton = {
    enable = lib.mkEnableOption "Enable Proton, a compatibility layer for running Windows games on Linux";
  };

  config = lib.mkIf cfg.enable {
    home.packages = (with pkgs; [
      protonup-qt
      protontricks
    ]);
  };
}
