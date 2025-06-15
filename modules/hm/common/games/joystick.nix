{ config, lib, pkgs, ... }:

let
  cfg = config.modules.hm.games.joystick;
in
{
  options.modules.hm.games.joystick = {
    enable = lib.mkEnableOption "Enable Joystick support for games";
  };

  config = lib.mkIf cfg.enable {
    home.packages = (with pkgs; [
      joystickwake
      qjoypad
    ]);
  };
}
