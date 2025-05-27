{ pkgs, lib, config, ... }:

let
  cfg = config.modules.common.emulator.proton;
in
{
  options.modules.common.emulator.proton = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable proton development environment";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = (with pkgs; [
      protonup-qt
      protontricks
    ]);
  };
}
