{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.modules.system.server.storage.gitea;
in
{
  options.modules.system.server.storage.gitea = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = "Enable Gitea service";
    };

    httpPort = mkOption {
      type = types.port;
      default = 3000;
      description = "HTTP port for Gitea";
    };

    stateDir = mkOption {
      type = types.path;
      default = "/var/lib/gitea";
      description = "Gitea state directory";
    };
  };

  config = mkIf cfg.enable {
    services.gitea = {
      enable = true;
      stateDir = cfg.stateDir;
      
      settings.server = {
        HTTP_PORT = cfg.httpPort;
      };
    };
  };
}