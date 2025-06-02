{ pkgs, lib, config, ... }:

let
  cfg = config.modules.common.documentation.okular;
in
{
  options.modules.common.documentation.okular = {
    enable = lib.mkEnableOption "Enable Okular document viewer";
  };

  config = lib.mkIf cfg.enable {
    home.packages = (with pkgs; [
      okular
    ]);
  };
}
