{ pkgs, lib, config, ... }:

let
  cfg = config.modules.common.dev.editor.android-studio;
in
{
  options.modules.common.dev.android-studio = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable android-studio development environment";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = (with pkgs; [
      android-studio
      android-studio-tools
    ]);
  };
}
