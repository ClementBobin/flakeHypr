{ pkgs, config, lib, ... }:

let
  cfg = config.modules.games.steam;
in
{
  options.modules.games.steam = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable games steam";
    };
  };

  config = lib.mkIf cfg.enable {

    environment.systemPackages = (with pkgs; [
      steam

      # Uncomment as needed:
      # inputs.nix-gaming.packages.${pkgs.system}.northstar-proton
      # inputs.nix-gaming.packages.${pkgs.system}.viper
      # inputs.nix-gaming.packages.${pkgs.system}.roblox-player
      # inputs.nix-gaming.packages.${pkgs.system}.rocket-league
      # inputs.nix-gaming.packages.${pkgs.system}.star-citizen
    ]);

    environment.sessionVariables = {
      STEAM_EXTRA_COMPAT_TOOLS_PATHS = "$HOME/.steam/root/compatibilitytools.d";
    };

    programs = {
      # GameMode for better performance (optional)
      gamemode.enable = true;
      gamescope = {
        enable = true;
        capSysNice = true;
      };
      steam = {
        enable = true;
        remotePlay.openFirewall = true;
        gamescopeSession.enable = true;
        #platformOptimizations.enable = true;
        localNetworkGameTransfers.openFirewall = true;
        dedicatedServer.openFirewall = true;
      };
    };
  };
}
