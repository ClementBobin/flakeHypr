{ pkgs, lib, config, ... }:

let
  cfg = config.modules.common.driver.chrome;
in
{
  options.modules.common.driver.chrome = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable chrome driver";
    };

    installMethod = lib.mkOption {
      type = lib.types.enum [ "hm" "sys" ];
      default = "hm";
      description = "Choose whether to install chrome driver via home-manager or directly in the environment.";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = lib.mkIf (cfg.installMethod == "hm") (with pkgs; [
      chromedriver
    ]);
  };
}
