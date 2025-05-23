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
  };

  config = lib.mkIf cfg.enable {
    home.packages = (with pkgs; [
      android-tools
      sdkmanager
    ]);
  };
}
