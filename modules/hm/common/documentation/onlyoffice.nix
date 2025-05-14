{ pkgs, lib, config, ... }:

let
  cfg = config.modules.common.documentation.onlyoffice;
in
{
  options.modules.common.documentation.onlyoffice = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable onlyofffice";
    };

    installMethod = lib.mkOption {
      type = lib.types.enum [ "hm" "sys" ];
      default = "hm";
      description = "Choose whether to install onlyoffice via home-manager or directly in the environment.";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = lib.mkIf (cfg.installMethod == "hm") (with pkgs; [
      onlyoffice-bin
    ]);
  };
}
