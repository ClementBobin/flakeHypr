{ pkgs, config, lib, vars, ... }:

let
  cfg = config.modules.system.server.media.multimedia;
  mediaUserGroup = "mediaServer";
in {
  options.modules.system.server.media.multimedia = {
    enable = lib.mkEnableOption "Enable the complete media server stack";

    user = lib.mkOption {
      type = lib.types.str;
      default = mediaUserGroup;
      description = "User to run all media services as";
    };
    group = lib.mkOption {
      type = lib.types.str;
      default = mediaUserGroup;
      description = "Group to run all media services as";
    };

    dataDir = lib.mkOption {
      type = lib.types.str;
      default = "/var/lib/${mediaUserGroup}";
      description = "Base directory for service data";
    };

    # Plex options
    plex = {
      enable = lib.mkEnableOption "Enable Plex Media Server";
      openFirewall = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Open firewall ports for Plex";
      };
    };

    # Jellyfin options
    jellyfin = {
      enable = lib.mkEnableOption "Enable Jellyfin Media Server";
      openFirewall = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Open firewall ports for Jellyfin";
      };
    };

    # Sonarr options
    sonarr = {
      enable = lib.mkEnableOption "Enable Sonarr";
      openFirewall = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Open firewall ports for Sonarr";
      };
    };

    # Radarr options
    radarr = {
      enable = lib.mkEnableOption "Enable Radarr";
      openFirewall = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Open firewall ports for Radarr";
      };
    };

    # Prowlarr options
    prowlarr = {
      enable = lib.mkEnableOption "Enable Prowlarr";
      openFirewall = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Open firewall ports for Prowlarr";
      };
    };

    # Bazarr options
    bazarr = {
      enable = lib.mkEnableOption "Enable Bazarr";
      openFirewall = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Open firewall ports for Bazarr";
      };
      listenPort = lib.mkOption {
        type = lib.types.port;
        default = 6767;
        description = "Port for Bazarr to listen on";
      };
    };

    # Flaresolverr options
    flaresolverr = {
      enable = lib.mkEnableOption "Enable Flaresolverr";
      openFirewall = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Open firewall ports for Flaresolverr";
      };
      port = lib.mkOption {
        type = lib.types.port;
        default = 8191;
        description = "Port for Flaresolverr to listen on";
      };
    };

    # Tautulli options
    tautulli = {
      enable = lib.mkEnableOption "Enable Tautulli";
      openFirewall = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Open firewall ports for Tautulli";
      };
      port = lib.mkOption {
        type = lib.types.port;
        default = 8181;
        description = "Port for Tautulli to listen on";
      };
    };

    # jellyseerr options
    jellyseerr = {
      enable = lib.mkEnableOption "Enable jellyseerr";
      openFirewall = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Open firewall ports for jellyseerr";
      };
      port = lib.mkOption {
        type = lib.types.port;
        default = 5055;
        description = "Port for jellyseerr to listen on";
      };
    };

    # qBittorrent options
    qbittorrent.enable = lib.mkEnableOption "Enable qBittorrent";

    # Shared storage options
    storage = {
      mediaDir = lib.mkOption {
        type = lib.types.str;
        default = "/data/${mediaUserGroup}";
        description = "Directory for media storage";
      };
      permissions = lib.mkOption {
        type = lib.types.str;
        default = "0775";
        description = "Permissions for media directories";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    # Create media group
    users.groups.${cfg.group} = {
      name = cfg.group;
      members = [ vars.user ];
    };

    # Create media user
    users.users.${cfg.user} = {
      group = cfg.group;
      home = cfg.dataDir;
      createHome = true;
      isSystemUser = true;
    };

    # Create required directories with proper permissions
    systemd.tmpfiles.rules = [
      "d ${cfg.dataDir} ${cfg.storage.permissions} ${cfg.user} ${cfg.group}"
      "Z ${cfg.dataDir} - ${cfg.user} ${cfg.group}"
      "d ${cfg.storage.mediaDir} ${cfg.storage.permissions} ${cfg.user} ${cfg.group}"
      "Z ${cfg.storage.mediaDir} - ${cfg.user} ${cfg.group}"
    ];

    # Configure services using the global user/group/dataDir
    services = {
      plex = lib.mkIf cfg.plex.enable {
        enable = true;
        openFirewall = cfg.plex.openFirewall;
        dataDir = "${cfg.dataDir}/plex";
        user = cfg.user;
        group = cfg.group;
      };

      jellyfin = lib.mkIf cfg.jellyfin.enable {
        enable = true;
        openFirewall = cfg.jellyfin.openFirewall;
        dataDir = "${cfg.dataDir}/jellyfin";
        user = cfg.user;
        group = cfg.group;
      };

      sonarr = lib.mkIf cfg.sonarr.enable {
        enable = true;
        openFirewall = cfg.sonarr.openFirewall;
        dataDir = "${cfg.dataDir}/sonarr";
        user = cfg.user;
        group = cfg.group;
      };

      radarr = lib.mkIf cfg.radarr.enable {
        enable = true;
        openFirewall = cfg.radarr.openFirewall;
        dataDir = "${cfg.dataDir}/radarr";
        user = cfg.user;
        group = cfg.group;
      };

      prowlarr = lib.mkIf cfg.prowlarr.enable {
        enable = true;
        openFirewall = cfg.prowlarr.openFirewall;
      };

      bazarr = lib.mkIf cfg.bazarr.enable {
        enable = true;
        openFirewall = cfg.bazarr.openFirewall;
        user = cfg.user;
        group = cfg.group;
        listenPort = cfg.bazarr.listenPort;
      };

      flaresolverr = lib.mkIf cfg.flaresolverr.enable {
        enable = true;
        openFirewall = cfg.flaresolverr.openFirewall;
        port = cfg.flaresolverr.port;
      };

      tautulli = lib.mkIf cfg.tautulli.enable {
        enable = true;
        openFirewall = cfg.tautulli.openFirewall;
        dataDir = "${cfg.dataDir}/tautulli";
        user = cfg.user;
        group = cfg.group;
        port = cfg.tautulli.port;
      };

      jellyseerr = lib.mkIf cfg.jellyseerr.enable {
        enable = true;
        openFirewall = cfg.jellyseerr.openFirewall;
        port = cfg.jellyseerr.port;
      };
    };

    # qBittorrent service
    systemd.services.qbittorrent = lib.mkIf cfg.qbittorrent.enable {
      description = "qBittorrent";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        Type = "simple";
        User = cfg.user;
        Group = cfg.group;
        ExecStart = "${pkgs.qbittorrent-enhanced-nox}/bin/qbittorrent-nox";
        WorkingDirectory = "${cfg.dataDir}/qbittorrent";
        Restart = "on-failure";
      };
    };
  };
}