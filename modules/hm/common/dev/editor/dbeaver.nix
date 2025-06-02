{ pkgs, lib, config, ... }:

let
  cfg = config.modules.common.dev.editor.dbeaver;
in
{
  options.modules.common.dev.editor.dbeaver = {
    enable = lib.mkEnableOption "Enable DBeaver database management tool";
  };

  config = lib.mkIf cfg.enable {
    home.packages = (with pkgs; [
      dbeaver-bin
    ]);
  };
}
