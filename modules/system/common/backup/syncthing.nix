{
  pkgs,
  config,
  lib,
  vars,
  ...
}:

let
  cfg = config.modules.backup.syncthing;
in
{
  options.modules.backup.syncthing = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable syncthing";
    };

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

    gui.enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable syncthing GUI";
    };
  };

  config = lib.mkIf cfg.enable {
    services.syncthing = {
      enable = true;
      guiAddress = "127.0.0.1:${toString cfg.port}";
      user = "${vars.user}";
      dataDir = "${cfg.dirSync}/${cfg.subDir}";  # default location for new folders
      configDir = "${cfg.dirSync}/.config/syncthing";
      openDefaultPorts = true;
    };
  };
}
