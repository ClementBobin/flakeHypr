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
  };

  config = lib.mkIf cfg.enable {
    home.packages = (with pkgs; [
      chromedriver
    ]);
  };
}
