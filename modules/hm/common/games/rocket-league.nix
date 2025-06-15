{ config, lib, pkgs, inputs, ... }:

let
  cfg = config.modules.hm.games.rocket-league;
in
{
  options.modules.hm.games.rocket-league = {
    enable = lib.mkEnableOption "Enable Rocket League game installation via nix-gaming";
  };

  config = lib.mkIf cfg.enable {
    home.packages = (with pkgs; [
      inputs.nix-gaming.packages.${pkgs.system}.rocket-league
    ]);
  };
}
