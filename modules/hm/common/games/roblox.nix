{ config, lib, pkgs, ... }:

let
  cfg = config.modules.common.games.roblox;
in
{
  options.modules.common.games.roblox = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable games roblox";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = (with pkgs; [
      inputs.nix-gaming.packages.${pkgs.system}.roblox-player
    ]);
  };
}
