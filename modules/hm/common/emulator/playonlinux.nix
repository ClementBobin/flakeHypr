{ pkgs, lib, config, ... }:

let
  cfg = config.modules.common.emulator.playonlinux;
in
{
  options.modules.common.emulator.playonlinux = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable playonlinux development environment";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = (with pkgs; [
      playonlinux
    ]);
  };
}
