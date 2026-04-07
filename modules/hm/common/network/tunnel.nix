{ pkgs, lib, config, ... }:

let
  cfg = config.modules.hm.network.tunnel;

  # Map services to their packages
  servicesToPackage = with pkgs; {
    localtunnel = [ nodePackages.localtunnel ];
  };

  # Tunnel command aliases
  tunnelAliases = {
    localtunnel = {
      ltn = "npx localtunnel --port ${toString cfg.localtunnel.port}";
      ltn-custom = "npx localtunnel --port";
    };
  };

  # Get packages for enabled services
  servicesPackages = lib.concatMap (service: servicesToPackage.${service} or []) cfg.services;

  # Get aliases for enabled services
  enabledAliases = lib.foldl (acc: service:
    acc // (tunnelAliases.${service} or {})
  ) {} cfg.services;

in {
  options.modules.hm.network.tunnel = {
    services = lib.mkOption {
      type = lib.types.listOf (lib.types.enum (lib.attrNames servicesToPackage));
      default = [];
      description = "List of tunneling services to enable";
    };

    localtunnel = {
      port = lib.mkOption {
        type = lib.types.port;
        default = 3000;
        description = "Default port for localtunnel";
      };
    };
  };

  config = lib.mkMerge [
    {
      home.packages = lib.unique servicesPackages;
      home.shellAliases = enabledAliases;
    }
  ];
}