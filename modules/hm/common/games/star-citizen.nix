{ config, lib, pkgs, inputs, ... }:

let
  cfg = config.modules.hm.games.star-citizen;
in
{
  options.modules.hm.games.star-citizen = {
    enable = lib.mkEnableOption "Enable Star Citizen Launcher";
  };

  config = lib.mkIf cfg.enable {
    home.packages = (with pkgs; [
      inputs.nix-gaming.packages.${pkgs.system}.star-citizen
    ]);
  };
}
