{ config, lib, pkgs, inputs, ... }:

let
  cfg = config.modules.hm.games;

  # Define all available games
  availableGames = {
    minecraft = {
      packages = with pkgs; [ prismlauncher jdk17 gcc glibc ];
      description = "Minecraft Launcher with PrismLauncher";
    };
    northstar = {
      packages = with inputs.nix-gaming.packages.${pkgs.system}; [ northstar-proton viper ];
      description = "Northstar (Titanfall 2 mod) with Proton and Viper";
    };
    roblox = {
      packages = with inputs.nix-gaming.packages.${pkgs.system}; [ roblox-player ];
      description = "Roblox Player";
    };
    rocket-league = {
      packages = with inputs.nix-gaming.packages.${pkgs.system}; [ rocket-league ];
      description = "Rocket League via nix-gaming";
    };
    star-citizen = {
      packages = with inputs.nix-gaming.packages.${pkgs.system}; [ star-citizen ];
      description = "Star Citizen Launcher";
    };
  };

  # Get list of game names for the enum type
  gameNames = builtins.attrNames availableGames;

  # Get packages for enabled games
  gamePackages = lib.unique (lib.concatMap (game: availableGames.${game}.packages) cfg.enabledGames);

in {
  options.modules.hm.games = {
    enabledGames = lib.mkOption {
      type = lib.types.listOf (lib.types.enum gameNames);
      default = [];
      description = "List of games to enable";
    };
  };

  config = lib.mkIf (cfg.enabledGames != []) {
    home.packages = gamePackages;
  };
}