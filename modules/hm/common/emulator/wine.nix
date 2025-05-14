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

    installMethod = lib.mkOption {
      type = lib.types.enum [ "hm" "sys" ];
      default = "hm";
      description = "Choose whether to install wine-related tools via home-manager or directly in the environment.";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = lib.mkIf (cfg.installMethod == "hm") (with pkgs; [
      wine
      winetricks
    ]);
  };
}
