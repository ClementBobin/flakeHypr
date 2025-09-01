{
  pkgs,
  config,
  lib,
  vars,
  ...
}:

let
  cfg = config.modules.system.server.storage.syncthing;
in
{
  options.modules.system.server.storage.syncthing = {
    enable = lib.mkEnableOption "Enable Syncthing for file synchronization";

    port = lib.mkOption {
      type = lib.types.port;
      default = 8384;
      description = "Port for syncthing GUI";
    };

    dirSync = lib.mkOption {
      type = lib.types.str;
      default = "/";
      description = "Directory containing sync principal";
    };

    subDir = lib.mkOption {
      type = lib.types.str;
      default = "";
      description = "Directory containing sync sub";
    };
  };

  config = lib.mkIf cfg.enable {
    services.syncthing = {
      enable = true;
      guiAddress = "127.0.0.1:${toString cfg.port}";
      user = vars.user;
      dataDir = lib.cleanSource "${cfg.dirSync}/${cfg.subDir}";  # default location for new folders
      configDir = "${cfg.dirSync}/.config/syncthing";
      openDefaultPorts = true;
    };

    systemd.services.syncthing = {
      description = "Syncthing service";
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];
      serviceConfig = {
        Type = "notify";
        Restart = "on-failure";
        RestartSec = 5;
      };
    };
  };
}
