{ config, lib, pkgs, inputs, ... }:

let
  cfg = config.modules.common.games.northstar;
in
{
  options.modules.common.games.northstar = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable games northstar-proton";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = (with pkgs; [
      inputs.nix-gaming.packages.${pkgs.system}.northstar-proton
      inputs.nix-gaming.packages.${pkgs.system}.viper
    ]);
  };
}
