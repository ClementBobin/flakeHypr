{ pkgs, lib, config, ... }:

let
  cfg = config.modules.common.dev.flutter;
in
{
  options.modules.common.dev.flutter = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable flutter development environment";
    };

    installMethod = lib.mkOption {
      type = lib.types.enum [ "hm" "sys" ];
      default = "hm";
      description = "Choose whether to install flutter via home-manager or directly in the environment.";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = lib.mkIf (cfg.installMethod == "hm") (with pkgs; [
      android-studio
      android-tools
      sdkmanager
    ]);
  };
}
