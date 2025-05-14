{ pkgs, lib, config, ... }:

let
  cfg = config.modules.common.dev.gitkraken;
in
{
  options.modules.common.dev.gitkraken = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable gitkraken development";
    };

    installMethod = lib.mkOption {
      type = lib.types.enum [ "hm" "sys" ];
      default = "hm";
      description = "Choose whether to install gitkraken tools via home-manager or directly in the environment.";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = lib.mkIf (cfg.installMethod == "hm") (with pkgs; [
      userPkgs.gitkraken
    ]);
  };
}
