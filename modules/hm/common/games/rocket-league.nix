{ config, lib, pkgs, inputs, ... }:

let
  cfg = config.modules.common.games.rocket-league;
in
{
  options.modules.common.games.rocket-league = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable games rocket-league";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = (with pkgs; [
      inputs.nix-gaming.packages.${pkgs.system}.rocket-league
    ]);
  };
}
