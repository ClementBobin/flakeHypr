{ pkgs, lib, config, ... }:

let
  cfg = config.modules.hm.communication.mail;

  serviceList = cfg.services;

  # Map service names to their corresponding packages or list of packages
  serviceToPackage = {
    thunderbird = [ ];
    bluemail    = [ pkgs.bluemail ];
  };

  # Flatten the list of packages from all enabled services
  packagesToInstall = lib.unique (lib.concatMap (s: serviceToPackage.${s}) serviceList);
in
{
  options.modules.hm.communication.mail = {
    services = lib.mkOption {
      type = lib.types.listOf (lib.types.enum (lib.attrNames serviceToPackage));
      default = [];
      description = "List of mail services to enable";
    };
  };

  config = {
    home.packages = packagesToInstall;

    programs.thunderbird = lib.mkIf (lib.elem "thunderbird" serviceList) {
      enable = true;
      profiles.default = {
        isDefault = lib.mkDefault true;
        settings = {
          "mail.spellcheck.inline" = true;
          "browser.display.use_system_colors" = true;
        };
      };
    };
  };
}