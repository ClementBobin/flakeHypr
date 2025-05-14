{ pkgs, lib, config, vars, ... }:

let
  cfg = config.modules.common.engine.unity;
in
{
  options.modules.common.engine.unity = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable unity support.";
    };

    installMethod = lib.mkOption {
      type = lib.types.enum [ "hm" "sys" ];
      default = "hm";
      description = ''
        Choose whether to install unity via home-manager or directly in the environment.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = lib.mkIf (cfg.installMethod == "hm") (with pkgs; [
      unityhub
    ]);
  };
}
