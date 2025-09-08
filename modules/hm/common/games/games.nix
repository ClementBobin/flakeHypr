{ config, lib, pkgs, inputs, ... }:

let
  cfg = config.modules.hm.games;

  # Define all available games
  availableGames = {
    minecraft = {
      packages = with pkgs; [ prismlauncher jdk17 gcc glibc ];
      description = "Minecraft Launcher with PrismLauncher";
    };
    titanfall2 = {
      packages = with inputs.nix-gaming.packages.${pkgs.system}; [ viper (lib.hiPrio northstar-proton) ];
      description = "Titanfall 2 via nix-gaming";
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
      packages = [ inputs.nix-gaming.packages.${pkgs.system}.star-citizen pkgs.lug-helper ];
      description = "Star Citizen Launcher";
    };
    geforce-now = {
      packages = with pkgs; [ gfn-electron];
      description = "NVIDIA GeForce Now Client";
    };
  };

  gameNames = builtins.attrNames availableGames;
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