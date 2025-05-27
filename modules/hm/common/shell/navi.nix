{ pkgs, lib, config, ... }:

let
  cfg = config.modules.common.shell.navi;
in
{
  options.modules.common.shell.navi = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable shell-navi";
    };
  };

    config = lib.mkIf cfg.enable {
      # Configure navi
      programs.navi = {
        # Enable btop
        enable = true;
      };
  };
}
