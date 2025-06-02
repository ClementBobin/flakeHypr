{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.modules.games.gamescope;
in
{
  options.modules.games.gamescope = {
    enable = mkEnableOption "Enable Gamescope compositor for gaming";
  };

  config = mkIf cfg.enable {
    # Add capability settings for gamescope
    security.wrappers.gamescope = {
      owner = "root";
      group = "root";
      capabilities = "cap_sys_nice+ep";
      source = "${pkgs.gamescope}/bin/gamescope";
    };
  };
}
