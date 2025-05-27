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
  };

  config = lib.mkIf cfg.enable {
    home.packages = (with pkgs; [
      onlyoffice-bin
    ]);
  };
}
