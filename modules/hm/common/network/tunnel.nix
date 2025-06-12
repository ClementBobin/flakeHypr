{ pkgs, lib, config, ... }:

let
  cfg = config.modules.common.network.tunnel;
  
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

  enabledAliases = lib.foldl (acc: service:
    acc // (tunnelAliases.${service} or {})
  ) {} cfg.service;
in
{
  options.modules.common.network.tunnel = {
    enable = lib.mkEnableOption "Enable network tunneling for development";

    service = lib.mkOption {
      type = lib.types.listOf (lib.types.enum ["localtunnel" "cloudflare" "ngrok"]);
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

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; (
      (lib.optionals (builtins.elem "localtunnel" cfg.service) [ nodePackages.localtunnel ]) ++
      (lib.optionals (builtins.elem "cloudflare" cfg.service) [ cloudflared ]) ++
      (lib.optionals (builtins.elem "ngrok" cfg.service) [ ngrok ])
    );

    home.shellAliases = enabledAliases;

    home.sessionVariables = lib.mkIf (builtins.elem "cloudflare" cfg.service && cfg.cloudflare.tokenPath != null) {
      CLOUDFLARE_TOKEN_FILE = cfg.cloudflare.tokenPath;
    };

    home.file = lib.mkMerge [
      (lib.mkIf (builtins.elem "cloudflare" cfg.service && cfg.cloudflare.tokenPath != null) {
        ".cloudflared/token".source = cfg.cloudflare.tokenPath;
      })
      (lib.mkIf (builtins.elem "ngrok" cfg.service && cfg.ngrok.configPath != null) {
        ".config/ngrok/ngrok.yml".source = cfg.ngrok.configPath;
      })
    ];
  };
}