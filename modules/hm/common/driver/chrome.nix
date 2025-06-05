{ pkgs, lib, config, ... }:

let
  cfg = config.modules.common.driver.chrome;
in
{
  options.modules.common.driver.chrome = {
    enable = lib.mkEnableOption "Enable Chrome WebDriver (chromedriver)";
  };

  config = lib.mkIf cfg.enable {
    home.packages = (with pkgs; [
      chromedriver
    ]);
  };
}
