{ pkgs, config, lib, ... }:

let
  cfg = config.modules.system.games;

  # Map gaming clients to their packages
  clientToPackage = with pkgs; {
    steam = [ steam ];
    lutris = [ lutris ];
    heroic = [ heroic ];
    nexus = [ nexusmods-app-unfree ];
  };

  # Get packages for enabled clients
  clientPackages = lib.concatMap (client: clientToPackage.${client} or []) cfg.clients;

in {
  options.modules.system.games = {
    clients = lib.mkOption {
      type = lib.types.listOf (lib.types.enum (lib.attrNames clientToPackage));
      default = [];
      description = ''
        List of gaming clients to enable. Supported options are "steam", "lutris",
        and "heroic". This allows you to specify which gaming clients should be
        configured in your NixOS setup.
      '';
    };

    steam.compatToolsPath = lib.mkOption {
      type = lib.types.path;
      default = "${builtins.getEnv "HOME"}/.steam/root/compatibilitytools.d";
      description = "Path for Steam compatibility tools";
    };

    gamemode = {
      enable = lib.mkEnableOption "Enable GameMode support";
      enableRenice = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable renice support in GameMode";
      };
      notificationCommands = lib.mkOption {
        type = lib.types.attrsOf lib.types.str;
        default = {
          start = "notify-send 'GameMode started'";
          end = "notify-send 'GameMode ended'";
        };
        description = "Custom notification commands for GameMode start and end events";
      };
      generalSettings = lib.mkOption {
        type = lib.types.attrsOf (lib.types.oneOf [ lib.types.int lib.types.bool lib.types.str ]);
        default = {
          inhibit_screensaver = 1;
        };
        description = "General GameMode settings";
      };
      gpuSettings = lib.mkOption {
        type = lib.types.attrsOf lib.types.str;
        default = {
          apply_gpu_optimisations = "accept-responsibility";
        };
        description = "GPU-related GameMode settings";
      };
    };
  };

  config = lib.mkMerge [
    {
      environment.systemPackages = lib.unique clientPackages;
      environment.sessionVariables = lib.mkIf (lib.elem "steam" cfg.clients) {
        STEAM_EXTRA_COMPAT_TOOLS_PATHS = cfg.steam.compatToolsPath;
      };
    }

    (lib.mkIf cfg.gamemode.enable {
      programs.gamemode = {
        enable = true;
        enableRenice = cfg.gamemode.enableRenice;
        settings = {
          general = cfg.gamemode.generalSettings;
          gpu = cfg.gamemode.gpuSettings;
          custom = cfg.gamemode.notificationCommands;
        };
      };
    })

    (lib.mkIf (lib.elem "steam" cfg.clients) {
      programs = {
        gamescope = {
          enable = true;
          capSysNice = true;
        };
        steam = {
          enable = true;
          remotePlay.openFirewall = true;
          gamescopeSession.enable = true;
          localNetworkGameTransfers.openFirewall = true;
          dedicatedServer.openFirewall = true;
        };
      };
    })
  ];
}