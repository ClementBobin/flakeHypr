{ pkgs, lib, config, ... }:

let
  cfg = config.modules.common.communication.teams;
in
{
  options.modules.common.communication.teams = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable teams";
    };

    installMethod = lib.mkOption {
      type = lib.types.enum [ "hm" "sys" ];
      default = "hm";
      description = "Choose whether to install teams via home-manager or directly in the environment.";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = lib.mkIf (cfg.installMethod == "hm") (with pkgs; [
      teams-for-linux
    ]);
  };
}
