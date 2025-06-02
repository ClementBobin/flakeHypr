{ pkgs, lib, config, ... }:

let
  cfg = config.modules.common.dev.flutter;
in
{
  options.modules.common.dev.flutter = {
    enable = lib.mkEnableOption "Enable Flutter development environment";
    extraPackages = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = [];
      description = "Additional Flutter packages to install";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = (with pkgs; [
      android-tools
      sdkmanager
    ] ++ cfg.extraPackages);
  };
}
