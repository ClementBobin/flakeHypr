{ pkgs, lib, config, ... }:

let
  cfg = config.modules.hm.network.tunnel;

  # Map services to their packages
  servicesToPackage = with pkgs; {
    localtunnel = [ nodePackages.localtunnel ];
    cloudflare = [ cloudflared ];
    ngrok = [ ngrok ];
  };

  # Tunnel command aliases
  tunnelAliases = {
    localtunnel = {
      ltn = "npx localtunnel --port ${toString cfg.localtunnel.port}";
      ltn-custom = "npx localtunnel --port";
    };
    cloudflare = {
      cft = "cloudflared tunnel --config ${cfg.cloudflare.configPath}";
    };
    ngrok = {
      ngt = "ngrok http ${toString cfg.ngrok.port}";
      ngt-custom = "ngrok http";
    };
  };

  # Get packages for enabled services
  servicesPackages = lib.concatMap (service: servicesToPackage.${service} or []) cfg.services;

  # Get aliases for enabled services
  enabledAliases = lib.foldl (acc: service:
    acc // (tunnelAliases.${service} or {})
  ) {} cfg.services;

  # Cloudflare token configuration
  cloudflareTokenConfig = lib.mkIf (builtins.elem "cloudflare" cfg.services && cfg.cloudflare.tokenPath != null) {
    home.sessionVariables.CLOUDFLARE_TOKEN_FILE = cfg.cloudflare.tokenPath;
    home.file.".cloudflared/token" = {
      source = cfg.cloudflare.tokenPath;
      target.recursive = true;
    };
  };

  ngrokConfig = lib.mkIf (builtins.elem "ngrok" cfg.services && cfg.ngrok.configPath != null) {
    home.file.".config/ngrok/ngrok.yml" = {
      source = cfg.ngrok.configPath;
      target.recursive = true;
    };
  };

in {
  options.modules.hm.network.tunnel = {
    services = lib.mkOption {
      type = lib.types.listOf (lib.types.enum (lib.attrNames servicesToPackage));
      default = ["localtunnel"];
      description = "List of tunneling services to enable";
    };

    localtunnel = {
      port = lib.mkOption {
        type = lib.types.port;
        default = 3000;
        description = "Default port for localtunnel";
      };
    };

    cloudflare = {
      configPath = lib.mkOption {
        type = lib.types.str;
        default = "${config.home.homeDirectory}/.cloudflared/config.yml";
        description = "Path to Cloudflare config file";
      };
      tokenPath = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "Path to Cloudflare token file";
      };
    };

    ngrok = {
      port = lib.mkOption {
        type = lib.types.port;
        default = 3000;
        description = "Default port for ngrok";
      };
      configPath = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "Path to ngrok config file";
      };
    };
  };

  config = lib.mkMerge [
    {
      home.packages = lib.unique servicesPackages;
      home.shellAliases = enabledAliases;
    }

    cloudflareTokenConfig
    ngrokConfig
  ];
}