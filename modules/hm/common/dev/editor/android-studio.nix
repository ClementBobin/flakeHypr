{ pkgs, lib, config, ... }:

let
  cfg = config.modules.hm.dev.editor.android-studio;
in
{
  options.modules.hm.dev.editor.android-studio = {
    enable = lib.mkEnableOption "Enable Android Studio development environment";
  };

  config = lib.mkIf cfg.enable {
    home.packages = (with pkgs; [
      android-studio
      android-studio-tools
    ]);
  };
}
