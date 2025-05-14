{ pkgs, lib, config, ... }:

let
  cfg = config.modules.common.documentation.okular;
in
{
  options.modules.common.documentation.okular = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable okular";
    };

    installMethod = lib.mkOption {
      type = lib.types.enum [ "hm" "sys" ];
      default = "hm";
      description = "Choose whether to install okular via home-manager or directly in the environment.";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = lib.mkIf (cfg.installMethod == "hm") (with pkgs; [
      okular
    ]);
  };
}
