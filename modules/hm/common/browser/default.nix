{ pkgs, lib, config, ... }:

let
  cfg = config.modules.common.browser;
in
{
  options.modules.common.browser = {
    emulators = lib.mkOption {
      type = lib.types.listOf (lib.types.enum ["chromium" "chrome" "firefox" "brave" "vivaldi" "edge"]);
      default = [];
    };

    driver.enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable browser drivers for automation (e.g., Selenium, Puppeteer)";
    };
  };

  config = {
    home.packages = with pkgs; (
      (lib.optionals (lib.elem "chromium" cfg.emulators) [chromium]) ++
      (lib.optionals (lib.elem "chrome" cfg.emulators) [google-chrome]) ++
      (lib.optionals (lib.elem "firefox" cfg.emulators) [firefox]) ++
      (lib.optionals (lib.elem "brave" cfg.emulators) [brave]) ++
      (lib.optionals (lib.elem "vivaldi" cfg.emulators) [vivaldi]) ++
      (lib.optionals (lib.elem "edge" cfg.emulators) [microsoft-edge]) ++

      (lib.optionals (cfg.driver.enable && lib.elem "chromium" cfg.emulators) [chromedriver]) ++
      (lib.optionals (cfg.driver.enable && lib.elem "chrome" cfg.emulators) [chromedriver]) ++
      (lib.optionals (cfg.driver.enable && lib.elem "firefox" cfg.emulators) [geckodriver]) ++
      (lib.optionals (cfg.driver.enable && lib.elem "edge" cfg.emulators) [msedgedriver])
    );
  };
}