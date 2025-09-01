{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.modules.system.server.media.paperless;
in {
  options.modules.system.server.media.paperless = {
    enable = mkEnableOption "Paperless document management system";

    dataDir = mkOption {
      type = types.path;
      default = "/var/lib/paperless";
      description = "Directory where Paperless stores its data.";
    };

    mediaDir = mkOption {
      type = types.path;
      default = "${cfg.dataDir}/media";
      description = "Directory where Paperless stores documents.";
    };

    consumptionDir = mkOption {
      type = types.nullOr types.path;
      default = "${cfg.dataDir}/consume";
      description = "Directory where Paperless monitors for new documents.";
    };

    consumptionDirIsPublic = mkOption {
      type = types.bool;
      default = true;
      description = "Whether the consumption directory should be world-readable.";
    };

    port = mkOption {
      type = types.port;
      default = 28981;
      description = "Port to listen on.";
    };

    settings = mkOption {
      type = types.attrsOf types.unspecified;
      default = {};
      description = "Paperless configuration settings.";
    };

    exporter = {
      enable = mkEnableOption "Paperless document exporter";

      directory = mkOption {
        type = types.path;
        default = "${cfg.dataDir}/export";
        description = "Directory where exports are stored.";
      };

      onCalendar = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = "Systemd calendar expression for when to run exports.";
      };
    };
  };

  config = {
    services.paperless = {
      enable = cfg.enable;
      dataDir = cfg.dataDir;
      mediaDir = cfg.mediaDir;
      consumptionDir = cfg.consumptionDir;
      consumptionDirIsPublic = cfg.consumptionDirIsPublic;
      port = cfg.port;
      settings = cfg.settings;

      exporter = {
        enable = cfg.exporter.enable;
        directory = cfg.exporter.directory;
        onCalendar = cfg.exporter.onCalendar;
      };
    };
  };
}