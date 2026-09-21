{ config, lib, pkgs-unstable, inputs, ... }:

let
  cfg = config.modules.hm.games;

  viper = pkgs-unstable.callPackage ../../../wrapper/viper.nix { };

  # Define all available games
  availableGames = {
    minecraft = {
      packages = with pkgs-unstable; [ prismlauncher jdk21 gcc glibc ];
      description = "Minecraft Launcher with PrismLauncher";
    };
    titanfall2 = {
      packages = [ viper (lib.hiPrio inputs.nix-gaming.packages.${pkgs-unstable.system}.northstar-proton) ];
      description = "Titanfall 2 via nix-gaming";
    };
    roblox = {
      packages = with inputs.nix-gaming.packages.${pkgs-unstable.system}; [ roblox-player ];
      description = "Roblox Player";
    };
    rocket-league = {
      packages = with inputs.nix-gaming.packages.${pkgs-unstable.system}; [ rocket-league ];
      description = "Rocket League via nix-gaming";
    };
    star-citizen = {
      packages = [ inputs.nix-gaming.packages.${pkgs-unstable.system}.star-citizen ]; #pkgs-unstable.lug-helper ];
      description = "Star Citizen Launcher";
    };
    geforce-now = {
      packages = with pkgs-unstable; [ gfn-electron];
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