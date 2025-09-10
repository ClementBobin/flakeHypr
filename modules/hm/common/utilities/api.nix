{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.modules.hm.utilities.api;
  scalarApp = (import ../../../wrapper/scalar.nix { inherit pkgs lib config; }).scalarApp;
in {
  options.modules.hm.utilities.api = {
    scalar.enable = mkEnableOption "Scalar desktop application";
  };

  config = {
    home.packages = [
      (lib.mkIf cfg.scalar.enable scalarApp)
    ];
    xdg.enable = true;
  };
}