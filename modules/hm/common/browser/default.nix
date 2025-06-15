{ pkgs, lib, config, ... }:

let
  cfg = config.modules.hm.browser;

  # Map browsers to their packages (using pkgs.)
  browserToPackage = with pkgs; {
    chromium = [ chromium ];
    chrome   = [ google-chrome ];
    firefox  = [ firefox ];
    brave    = [ brave ];
    vivaldi  = [ vivaldi ];
    edge     = [ microsoft-edge ];
  };

  # Map browsers to their drivers (using pkgs.)
  browserToDriver = with pkgs; {
    chromium = chromedriver;
    chrome   = chromedriver;
    vivaldi  = chromedriver;
    brave    = chromedriver;
    firefox  = geckodriver;
    edge     = msedgedriver;
  };

  # Get packages for enabled browsers
  browserPackages = lib.concatMap (browser: browserToPackage.${browser} or []) cfg.emulators;

  # Get drivers for enabled browsers (if driver.enable is true)
  drivers = lib.optionals cfg.driver.enable (
    lib.unique (lib.filter (drv: drv != null) (
      map (browser: browserToDriver.${browser} or null) cfg.emulators
    ))
  );

in
{
  options.modules.hm.browser = {
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
    home.packages = lib.unique (browserPackages ++ drivers);
  };
}