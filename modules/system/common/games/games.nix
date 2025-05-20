{ pkgs, config, lib, ... }:

let
  cfg = config.modules.games;
in
{
  options.modules.games = {
    enable = lib.mkEnableOption "Enable all gaming-related configuration";

    steam.enable = lib.mkEnableOption "Enable Steam support";
    lutris.enable = lib.mkEnableOption "Enable Lutris support";
    heroic.enable = lib.mkEnableOption "Enable Heroic support";
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; lib.flatten [
      (lib.optional cfg.steam.enable steam)
      (lib.optional cfg.lutris.enable lutris)
      (lib.optional cfg.heroic.enable heroic)
    ];

    environment.sessionVariables = lib.mkIf cfg.steam.enable {
      STEAM_EXTRA_COMPAT_TOOLS_PATHS = "$HOME/.steam/root/compatibilitytools.d";
    };

    programs = lib.mkMerge [
      (lib.mkIf cfg.steam.enable {
        gamemode.enable = true;
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