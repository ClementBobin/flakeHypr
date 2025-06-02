{ pkgs, lib, config, ... }:

let
  cfg = config.modules.common.emulator.playonlinux;
in
{
  options.modules.common.emulator.playonlinux = {
    enable = lib.mkEnableOption "Enable PlayOnLinux, a graphical frontend for Wine";
  };

  config = lib.mkIf cfg.enable {
    home.packages = (with pkgs; [
      playonlinux
    ]);
  };
}
