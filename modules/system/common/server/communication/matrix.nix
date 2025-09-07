{ config, pkgs, lib, ... }:

let
  cfg = config.modules.system.server.communication.matrix-synapse;
in
{
  options.modules.system.server.communication.matrix-synapse = {
    enable = lib.mkEnableOption "Matrix Synapse homeserver";

    serverName = lib.mkOption {
      type = lib.types.str;
      default = "${config.networking.hostName}.com";
      example = "example.com";
      description = "The public server name for Matrix federation";
    };

    publicBaseUrl = lib.mkOption {
      type = lib.types.str;
      default = "https://matrix.${cfg.serverName}";
      description = "Public base URL for client access";
    };

    enableRegistration = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether to allow new user registration";
    };

    registrationRequireToken = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Whether registration requires an access token";
    };

    databaseType = lib.mkOption {
      type = lib.types.enum [ "sqlite" "postgres" ];
      default = "sqlite";
      description = "Database backend to use";
    };

    postgres = {
      host = lib.mkOption {
        type = lib.types.str;
        default = "/run/postgresql";
        description = "PostgreSQL host (path to socket for local)";
      };

      database = lib.mkOption {
        type = lib.types.str;
        default = "matrix-synapse";
        description = "PostgreSQL database name";
      };

      username = lib.mkOption {
        type = lib.types.str;
        default = "matrix-synapse";
        description = "PostgreSQL username";
      };
    };

    enableMetrics = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether to enable Prometheus metrics endpoint";
    };

    logLevel = lib.mkOption {
      type = lib.types.enum [ "DEBUG" "INFO" "WARNING" "ERROR" "CRITICAL" ];
      default = "INFO";
      description = "Logging level";
    };

    extraConfig = lib.mkOption {
      type = lib.types.attrs;
      default = {};
      description = "Additional configuration options";
    };
  };

  config = lib.mkIf cfg.enable {
    services.matrix-synapse = {
      enable = true;
      
      settings = lib.recursiveUpdate {
        server_name = cfg.serverName;
        public_baseurl = cfg.publicBaseUrl;
        
        enable_registration = cfg.enableRegistration;
        registration_requires_token = cfg.registrationRequireToken;
        
        database = if cfg.databaseType == "postgres" then {
          name = "psycopg2";
          args = {
            user = cfg.postgres.username;
            database = cfg.postgres.database;
            host = cfg.postgres.host;
          };
        } else {
          name = "sqlite3";
          args.database = "/var/lib/matrix-synapse/homeserver.db";
        };
        
        listeners = [
          {
            port = 8008;
            bind_addresses = [ "::1" "127.0.0.1" ];
            type = "http";
            tls = false;
            x_forwarded = true;
            resources = [
              {
                names = [ "client" "federation" ];
                compress = false;
              }
            ];
          }
        ] ++ lib.optional cfg.enableMetrics {
          port = 9000;
          bind_addresses = [ "::1" "127.0.0.1" ];
          type = "metrics";
          tls = false;
        };
        
        log_config = "/var/lib/matrix-synapse/${cfg.logLevel}.log.config";
        
        # Basic rate limiting
        rc_messages_per_second = 10;
        rc_message_burst_count = 100;
      } cfg.extraConfig;
    };

    # PostgreSQL configuration if selected
    services.postgresql = lib.mkIf (cfg.databaseType == "postgres") {
      enable = true;
      ensureDatabases = [ cfg.postgres.database ];
      ensureUsers = [
        {
          name = cfg.postgres.username;
          ensureDBOwnership = true;
        }
      ];
    };

    # Reverse proxy configuration
    services.nginx = {
      enable = true;
      virtualHosts."${cfg.publicBaseUrl}" = {
        forceSSL = false;
        serverAliases = [ cfg.serverName ];
        
        locations."/" = {
          proxyPass = "http://[::1]:8008";
          proxyWebsockets = true;
          recommendedProxySettings = true;
        };

        locations."/_matrix" = {
          proxyPass = "http://[::1]:8008";
          proxyWebsockets = true;
          recommendedProxySettings = true;
        };
      };
    };
    
    # Firewall configuration
    networking.firewall.allowedTCPPorts = [ 80 443 ];
    
    # Systemd service hardening
    systemd.services.matrix-synapse = {
      serviceConfig = {
        PrivateTmp = true;
        ProtectSystem = "strict";
        ProtectHome = true;
        PrivateDevices = true;
        NoNewPrivileges = true;
      };
    };

    # Integration for matrix
    #services = {
      #matrix-hookshot.enable = true;
    #};
  };
}