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

    installMethod = lib.mkOption {
      type = lib.types.enum [ "hm" "sys" ];
      default = "hm";
      description = "Choose whether to install dbeaver tools via home-manager or directly in the environment.";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = lib.mkIf (cfg.installMethod == "hm") (with pkgs; [
      dbeaver-bin
    ]);
  };
}
