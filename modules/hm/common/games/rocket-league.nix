{ config, lib, pkgs, inputs, ... }:

let
  cfg = config.modules.common.games.rocket-league;
in
{
  options.modules.common.games.rocket-league = {
    enable = lib.mkEnableOption "Enable Rocket League Launcher";
  };

  config = lib.mkIf cfg.enable {
    home.packages = (with pkgs; [
      inputs.nix-gaming.packages.${pkgs.system}.rocket-league
    ]);
  };
}
