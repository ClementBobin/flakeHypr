{ pkgs, lib, config, ... }:

let
  cfg = config.modules.hm.utilities.api;

  # Map client to their packages
  clientToPackage = {
    scalar = (import ../../../wrapper/scalar.nix { inherit pkgs lib config; }).scalarApp;
    yaak   = pkgs.yaak;
    requestly = pkgs.requestly;
  };

  # Get packages for enabled clients
  clientPackages = lib.filter (pkg: pkg != null)
    (map (client: clientToPackage.${client} or null) cfg.clients);

in {
  options.modules.hm.utilities.api = {
    clients = lib.mkOption {
      type = lib.types.listOf (lib.types.enum (lib.attrNames clientToPackage));
      default = [];
      description = ''
        Select which utilities (clients API) to install on your system.
        You can choose one or multiple clients.
      '';
    };
  };

  config = {
    home.packages = clientPackages;
    xdg.enable = true;
  };
}
