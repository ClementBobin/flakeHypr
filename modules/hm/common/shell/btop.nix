{ pkgs, lib, config, ... }:

let
  cfg = config.modules.common.shell.btop;
in
{
  options.modules.common.shell.btop = {
    enable = lib.mkEnableOption "Enable btop system monitor";
  };

  config = lib.mkIf cfg.enable {
      # Configure btop
      programs.btop = {

        # Enable btop
        enable = true;

        # Configuration for btop
        settings = {

          # Use default terminal background
          theme_background = false;

          # Use vim keys
          vim_keys = true;

          # Organise processes as a tree by default
          proc_tree = true;
        };
      };
  };
}
