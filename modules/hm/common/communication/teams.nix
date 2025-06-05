{ pkgs, lib, config, ... }:

let
  cfg = config.modules.common.communication.teams;
in
{
  options.modules.common.communication.teams = {
    enable = lib.mkEnableOption "Enable Microsoft Teams for Linux";
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      teams-for-linux
    ];
  };
}
