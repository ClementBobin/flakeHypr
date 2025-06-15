{ config, lib, pkgs, inputs, ... }:

let
  cfg = config.modules.hm.games.roblox;
in
{
  options.modules.hm.games.roblox = {
    enable = lib.mkEnableOption "Enable Roblox Player";
  };

  config = lib.mkIf cfg.enable {
    home.packages = (with pkgs; [
      inputs.nix-gaming.packages.${pkgs.system}.roblox-player
    ]);
  };
}
