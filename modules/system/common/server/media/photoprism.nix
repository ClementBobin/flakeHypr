{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.modules.system.server.media.photoprism;
in
{
  options.modules.system.server.media.photoprism = {
    enable = lib.mkEnableOption "Enable photoprism server";
    storagePath = lib.mkOption {
      type = lib.types.str;
      default = "/var/lib/photoprism";
      description = "Base directory for photoprism data";
    };
    originalsPath = lib.mkOption {
      type = lib.types.str;
      default = "${cfg.storagePath}/originals";
      description = "Path to your original photos directory";
    };
    settings = lib.mkOption {
      type = lib.types.attrsOf lib.types.anything;
      default = {};
      description = "Custom settings for photoprism configuration";
    };
    port = lib.mkOption {
      type = lib.types.port;
      default = 2342;
      description = "Port for the photoprism web interface";
    };
  };

  config = lib.mkIf cfg.enable {
    services.photoprism = {
      enable = true;
      port = cfg.port;
      originalsPath = cfg.originalsPath;
      storagePath = cfg.storagePath;
      settings = cfg.settings;
    };
  };
}