{ pkgs, lib, config, ... }:

let
  cfg = config.modules.common.emulator.wine;
in
{
  options.modules.common.emulator.wine = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable wine development environment";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = (with pkgs; [
      wine
      winetricks
    ]);
  };
}
