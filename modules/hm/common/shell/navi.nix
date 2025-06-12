{ pkgs, lib, config, ... }:

let
  cfg = config.modules.common.shell.navi;
in
{
  options.modules.common.shell.navi = {
    enable = lib.mkEnableOption "Enable Navi (CLI cheat sheet tool)";
  };

    config = lib.mkIf cfg.enable {
      # Configure navi
      programs.navi = {
        # Enable navi
        enable = true;
      };
  };
}
