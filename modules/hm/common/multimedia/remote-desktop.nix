{ pkgs, lib, config, ... }:

let
  cfg = config.modules.hm.multimedia.remote-desktop;

  # Map clients to their packages
  clientsToPackage = with pkgs; {
    parsec = [ parsec-bin ];
    rustdesk = [ rustdesk ];
  };

  # Get packages for enabled clients
  clientsPackages = lib.concatMap (service: clientsToPackage.${service} or []) cfg.clients;
in
{
  options.modules.hm.multimedia.remote-desktop = {
    clients = lib.mkOption {
      type = lib.types.listOf (lib.types.enum (lib.attrNames clientsToPackage));
      default = [];
      description = "List of remote desktop clients to enable";
    };
  };

  config.home.packages = clientsPackages;
}
