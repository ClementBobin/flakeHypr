{ config, lib, pkgs, inputs, ... }:

let
  cfg = config.modules.common.games.northstar;
in
{
  options.modules.common.games.northstar = {
    enable = lib.mkEnableOption "Enable Northstar (Titanfall 2 mod) with Proton and Viper";
  };

  config = lib.mkIf cfg.enable {
    home.packages = (with pkgs; [
      inputs.nix-gaming.packages.${pkgs.system}.northstar-proton
      inputs.nix-gaming.packages.${pkgs.system}.viper
    ]);
  };
}
