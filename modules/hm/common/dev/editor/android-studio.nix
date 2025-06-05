{ pkgs, lib, config, ... }:

let
  cfg = config.modules.common.dev.editor.android-studio;
in
{
  options.modules.common.dev.editor.android-studio = {
    enable = lib.mkEnableOption "Enable Android Studio development environment";
  };

  config = lib.mkIf cfg.enable {
    home.packages = (with pkgs; [
      android-studio
      android-studio-tools
    ]);
  };
}
