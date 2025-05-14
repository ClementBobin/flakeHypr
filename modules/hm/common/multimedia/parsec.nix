{ pkgs, lib, config, ... }:

let
  cfg = config.modules.common.multimedia.parsec;
in
{
  options.modules.common.multimedia.parsec = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable parsec";
    };

    installMethod = lib.mkOption {
      type = lib.types.enum [ "hm" "sys" ];
      default = "hm";
      description = "Choose whether to install parsec via home-manager or directly in the environment.";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = lib.mkIf (cfg.installMethod == "hm") (with pkgs; [
      parsec-bin
    ]);
  };
}
