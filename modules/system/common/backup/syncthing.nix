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
      user = "${vars.user}";
      dataDir = "${cfg.dirSync}/${cfg.subDir}";  # default location for new folders
      configDir = "${cfg.dirSync}/.config/syncthing";
      openDefaultPorts = true;
    };
  };
}
