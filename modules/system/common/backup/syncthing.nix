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
  };

  config = lib.mkIf cfg.enable {
    services.syncthing = {
      enable = true;
      user = "${vars.user}";
      dataDir = "/home/${vars.user}";  # default location for new folders
      configDir = "/home/${vars.user}/.config/syncthing";
      openDefaultPorts = true;
    };
  };
}
