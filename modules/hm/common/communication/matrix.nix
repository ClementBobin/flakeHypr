{ pkgs, lib, config, ... }:

let
  cfg = config.modules.hm.communication.matrix;

  # Map clients to their packages
  clientsToPackage = with pkgs; {
    element = [ ];
    nheko = [ ];
  };

  # Get packages for enabled clients
  clientPackages = lib.concatMap (client: clientsToPackage.${client} or []) cfg.clients;

in {
  options.modules.hm.communication.matrix = {
    clients = lib.mkOption {
      type = lib.types.listOf (lib.types.enum (lib.attrNames clientsToPackage));
      default = [];
      description = "List of clients to install";
    };
  };

  config = {
    home.packages = clientPackages;

    programs = {
      element-desktop.enable = lib.elem "element" cfg.clients;
      nheko.enable = lib.elem "nheko" cfg.clients;
    };
  };
}