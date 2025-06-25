{ pkgs, lib, config, ... }:

let
  cfg = config.modules.hm.shell.navi;
in
{
  options.modules.hm.shell.navi = {
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
