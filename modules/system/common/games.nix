{ pkgs, config, lib, ... }:

let
  cfg = config.modules.system.games;

  # Map gaming clients to their packages
  clientToPackage = with pkgs; {
    steam = [ ];
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
        List of gaming clients to install and configure.
        
        Supported options:
        - "steam": Valve's Steam gaming platform with Proton compatibility
        - "lutris": Open gaming platform that manages games from different sources
        - "heroic": Alternative game launcher for Epic Games Store and GOG
        - "nexus": Nexus Mods application for managing game modifications
        
        Note: Enabling "steam" automatically configures additional components
        like gamescope and Proton compatibility tools.
      '';
    };

    steam.compatToolsPath = lib.mkOption {
      type = lib.types.str;
      default = "~/.local/share/Steam/compatibilitytools.d";
      example = "/home/user/.local/share/Steam/compatibilitytools.d";
      description = ''
        Path where Steam compatibility tools (like Proton-GE) should be installed.
        
        This directory is used by Steam to find custom Proton versions and
        other compatibility tools. The path is exposed via the
        STEAM_EXTRA_COMPAT_TOOLS_PATHS environment variable.
        
        Defaults to the standard Steam installation location.
      '';
    };

    steamtinkerlauncher = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = ''
        Enable integration with Steam Tinker Launcher (STL).
        
        STL is a third-party tool that provides advanced management of Steam
        Proton versions and game-specific configurations. Enabling this option
        allows the system to automatically detect and configure STL for use with
        Steam games.
        
        This includes setting up necessary environment variables and ensuring
        compatibility with the configured Proton versions.
      '';
    };

    gamemode = {
      enable = lib.mkEnableOption ''
        Feral Interactive's GameMode optimization daemon
        
        GameMode is a tool that optimizes Linux system performance on demand.
        When activated, it applies various optimizations like:
        - CPU governor tuning
        - Process priority (nice level) adjustment
        - I/O priority tuning
        - Kernel scheduler adjustment
        - GPU performance mode setting (for supported GPUs)
        
        Games and applications can request GameMode through the libgamemode library.
      '';

      enableRenice = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = ''
          Enable process priority (renice) optimization in GameMode.
          
          When enabled, GameMode will adjust the nice level of the game process
          and its children to give them higher scheduling priority.
          
          This generally improves game performance but may affect system
          responsiveness for other applications while gaming.
        '';
      };

      notificationCommands = lib.mkOption {
        type = lib.types.attrsOf lib.types.str;
        default = {
          start = "notify-send 'GameMode started'";
          end = "notify-send 'GameMode ended'";
        };
        example = lib.literalExpression ''
          {
            start = "notify-send -u critical 'GameMode' 'Optimizations activated'";
            end = "notify-send -u normal 'GameMode' 'Optimizations deactivated'";
          }
        '';
        description = ''
          Custom shell commands to execute when GameMode starts and stops.
          
          These commands are executed as the user who launched the game.
          The default configuration uses notify-send to display desktop
          notifications.
          
          You can customize these to:
          - Change notification appearance
          - Log GameMode events
          - Trigger other automation scripts
          - Control RGB lighting or other peripherals
        '';
      };

      generalSettings = lib.mkOption {
        type = lib.types.attrsOf (lib.types.oneOf [ lib.types.int lib.types.bool lib.types.str ]);
        default = {
          inhibit_screensaver = 1;
        };
        example = lib.literalExpression ''
          {
            inhibit_screensaver = 1;
            desiredgov = "performance";
            softrealtime = "auto";
          }
        '';
        description = ''
          General GameMode configuration settings.
          
          Common settings include:
          - inhibit_screensaver: Prevent screen blanking during gameplay (0/1)
          - desiredgov: CPU governor to use ("performance", "powersave", etc.)
          - softrealtime: Enable soft real-time scheduling ("auto", "on", "off")
          - ioprio: I/O priority for game processes
          - renice: Nice level adjustment value
          
          See the GameMode documentation for a complete list of available options.
        '';
      };

      gpuSettings = lib.mkOption {
        type = lib.types.attrsOf lib.types.str;
        default = {
          apply_gpu_optimisations = "accept-responsibility";
        };
        example = lib.literalExpression ''
          {
            apply_gpu_optimisations = "accept-responsibility";
            gpu_device = "0";
            amd_performance_level = "high";
          }
        '';
        description = ''
          GPU-specific optimization settings for GameMode.
          
          These settings control GPU performance states and optimizations.
          The "accept-responsibility" value is required to acknowledge that
          GPU overclocking/optimizations may potentially damage hardware.
          
          GPU vendor-specific options:
          - AMD: amd_performance_level, amd_power_profile
          - NVIDIA: nvidia_clock_offset, nvidia_mem_offset
          - Intel: intel_max_perf, intel_min_perf
          
          Use with caution and ensure proper cooling for your GPU.
        '';
      };
    };
  };

  config = lib.mkMerge [
    {
      environment.systemPackages = lib.unique clientPackages ++ (if cfg.steamtinkerlauncher then [ pkgs.steamtinkerlaunch ] else []);
      environment.sessionVariables = lib.mkIf (lib.elem "steam" cfg.clients) {
        STEAM_EXTRA_COMPAT_TOOLS_PATHS = cfg.steam.compatToolsPath;
      };
      environment.shellAliases = {
        stl = lib.optionalString cfg.steamtinkerlauncher "steam-tinker-launcher";
        recursion = lib.optionalString cfg.steamtinkerlauncher ''
          if [ -d "~/games/SteamLibrary/steamapps/compatdata/218230/pfx" ]; then
            cd ~/games/SteamLibrary/steamapps/compatdata/218230/pfx
            WINEPREFIX=$PWD wine explorer /desktop=Recursion,1920x1080 "drive_c/Program Files (x86)/Recursion/RecursionTracker/RTST.exe"
          else
            echo "Recursion directory not found"
          fi
        '';
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
          protontricks.enable = true;
          localNetworkGameTransfers.openFirewall = true;
          dedicatedServer.openFirewall = true;
          extraCompatPackages = with pkgs; [
            proton-ge-bin
            steam-play-none
          ];
        };
      };
    })
  ];
}