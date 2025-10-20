{ pkgs, lib, config, ... }:

let
  cfg = config.modules.hm.multimedia.management-utility;
  hyprdisplays = pkgs.callPackage ../../../wrapper/hyprDisplays.nix {};

  clientsList = cfg.clients;

  # Map service names to their corresponding packages or list of packages
  clientsToPackage = {
    hyprdisplays = [ hyprdisplays ];
    nwg-displays    = [ pkgs.nwg-displays ];
    wdisplays = [ pkgs.wdisplays ];
    wlay = [ pkgs.wlay ];
  };

  # Flatten the list of packages from all enabled clients
  packagesToInstall = lib.unique (lib.concatMap (s: clientsToPackage.${s}) clientsList);
in
{
  options.modules.hm.multimedia.management-utility = {
    clients = lib.mkOption {
      type = lib.types.listOf (lib.types.enum (lib.attrNames clientsToPackage));
      default = [ ];
      description = "List of display management utilities to enable";
    };
  };

  config = {
    home.packages = packagesToInstall;
  };
}
