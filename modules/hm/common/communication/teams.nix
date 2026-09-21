{ pkgs-unstable, lib, config, ... }:

let
  cfg = config.modules.hm.communication.teams;
in
{
  options.modules.hm.communication.teams = {
    enable = lib.mkEnableOption "Enable Microsoft Teams for Linux";
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs-unstable; [
      teams-for-linux
    ];
  };
}
