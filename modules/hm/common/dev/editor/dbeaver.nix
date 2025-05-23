{ pkgs, lib, config, ... }:

let
  cfg = config.modules.common.dev.editor.dbeaver;
in
{
  options.modules.common.dev.editor.dbeaver = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable dbeaver development";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = (with pkgs; [
      dbeaver-bin
    ]);
  };
}
