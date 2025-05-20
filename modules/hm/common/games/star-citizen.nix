{ config, lib, pkgs, ... }:

let
  cfg = config.modules.common.games.star-citizen;
in
{
  options.modules.common.games.star-citizen = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable games star-citizen";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = (with pkgs; [
      inputs.nix-gaming.packages.${pkgs.system}.star-citizen
    ]);
  };
}
