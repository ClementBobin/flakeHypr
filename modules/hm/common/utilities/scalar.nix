{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.modules.hm.utilities.scalar;
  scalarApp = (import ../../../wrapper/scalar.nix { inherit pkgs lib config; }).scalarApp;
in {
  options.modules.hm.utilities.scalar = {
    enable = mkEnableOption "Scalar desktop application";
  };

  config = mkIf cfg.enable {
    home.packages = [ scalarApp ];
    xdg.enable = true;
  };
}