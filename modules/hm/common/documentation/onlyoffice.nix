{ pkgs, lib, config, ... }:

let
  cfg = config.modules.common.documentation.onlyoffice;
in
{
  options.modules.common.documentation.onlyoffice = {
    enable = lib.mkEnableOption "Enable OnlyOffice document editor";
  };

  config = lib.mkIf cfg.enable {
    home.packages = (with pkgs; [
      onlyoffice-bin
    ]);
  };
}
