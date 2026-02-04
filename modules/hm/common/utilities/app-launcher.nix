{ pkgs, lib, config, ... }:

let
  cfg = config.modules.hm.utilities.app-launcher;

  clientsToPackage = with pkgs; {
    hyprshell = [ hyprshell ];
  };

  themeRepo = {
    owner = "kando-menu";
    repo = "menu-themes";
    tag = "v0.2.0";
  };

  clientsPackages = lib.concatMap (client: clientsToPackage.${client} or []) cfg.clients;
in {
  options.modules.hm.utilities.app-launcher = {
    clients = lib.mkOption {
      type = lib.types.listOf (lib.types.enum (lib.attrNames clientsToPackage));
      default = [];
      description = "List of application launchers to enable";
    };
  };

  config = {
    home.packages = clientsPackages;
  };
}