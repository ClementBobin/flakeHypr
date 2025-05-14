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

    installMethod = lib.mkOption {
      type = lib.types.enum [ "hm" "sys" ];
      default = "hm";
      description = "Choose whether to install playonlinux-related tools via home-manager or directly in the environment.";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = lib.mkIf (cfg.installMethod == "hm") (with pkgs; [
      playonlinux
    ]);
  };
}
