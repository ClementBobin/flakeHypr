{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.modules.system.server.storage.forgejo;
in
{
  options.modules.system.server.storage.forgejo = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = "Enable Forgejo service";
    };

    httpPort = mkOption {
      type = types.port;
      default = 3000;
      description = "HTTP port for Forgejo";
    };

    stateDir = mkOption {
      type = types.path;
      default = "/var/lib/forgejo";
      description = "Forgejo state directory";
    };
  };

  config = mkIf cfg.enable {
    services.forgejo = {
      enable = true;
      stateDir = cfg.stateDir;
      
      settings.server = {
        HTTP_PORT = cfg.httpPort;
      };
    };
  };
}