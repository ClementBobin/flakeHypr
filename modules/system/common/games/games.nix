{ pkgs, config, lib, ... }:

let
  cfg = config.modules.games;
in
{
  options.modules.games = {
    enable = lib.mkEnableOption "Enable all gaming-related configuration";

    steam = {
      compatToolsPath = lib.mkOption {
        type = lib.types.str;
        default = "$HOME/.steam/root/compatibilitytools.d";
        description = "Path for Steam compatibility tools";
      };
      enable = lib.mkEnableOption "Enable Steam support";
    };

    lutris.enable = lib.mkEnableOption "Enable Lutris support";
    heroic.enable = lib.mkEnableOption "Enable Heroic support";

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
        type = lib.types.attrsOf lib.types.int;
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

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs;
      lib.optional cfg.steam.enable steam
      ++ lib.optional cfg.lutris.enable lutris
      ++ lib.optional cfg.heroic.enable heroic;

    environment.sessionVariables = lib.mkIf cfg.steam.enable {
      STEAM_EXTRA_COMPAT_TOOLS_PATHS = cfg.steam.compatToolsPath;
    };

    programs = lib.mkMerge [
      (lib.mkIf cfg.gamemode.enable {
        gamemode = {
          enable = true;
          enableRenice = cfg.gamemode.enableRenice;
          settings = {
            general = cfg.gamemode.generalSettings;
            gpu = cfg.gamemode.gpuSettings;
            custom = cfg.gamemode.notificationCommands;
          };
        };
      })

      (lib.mkIf cfg.steam.enable {
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
      })
    ];
  };
}