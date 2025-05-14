{ pkgs, lib, config, ... }:

let
  cfg = config.modules.common.security.stacer;
in
{
  options.modules.common.security.stacer = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable stacer.";
    };

    installMethod = lib.mkOption {
      type = lib.types.enum [ "hm" "sys" ];
      default = "hm";
      description = "Choose whether to install stacer via home-manager or directly in the environment.";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = lib.mkIf (cfg.installMethod == "hm") (with pkgs; [
      stacer
    ]);
  };
}
