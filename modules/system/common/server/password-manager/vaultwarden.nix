{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.modules.system.server.security.password-manager.vaultwarden;
in
{
  options.modules.system.server.security.password-manager.vaultwarden = {
    enable = lib.mkEnableOption "Enable Vaultwarden server";
    backupDir = lib.mkOption {
      type = lib.types.str;
      default = "/var/backup/vaultwarden";
      description = "Base directory for Vaultwarden data";
    };
    settings = lib.mkOption {
      type = lib.types.attrsOf lib.types.anything;
      default = {};
      description = "Custom settings for photoprism configuration";
    };
  };

  config = {
    services.vaultwarden = {
      enable = cfg.enable;
      backupDir = cfg.backupDir;
      config = cfg.settings;
    };
  };
}
