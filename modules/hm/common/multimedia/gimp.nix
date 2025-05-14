{ pkgs, lib, config, ... }:

let
  cfg = config.modules.common.multimedia.gimp;
in
{
  options.modules.common.multimedia.gimp = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable gimp";
    };

    installMethod = lib.mkOption {
      type = lib.types.enum [ "hm" "sys" ];
      default = "hm";
      description = "Choose whether to install gimp via home-manager or directly in the environment.";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = lib.mkIf (cfg.installMethod == "hm") (with pkgs; [
      gimp
    ]);
  };
}
