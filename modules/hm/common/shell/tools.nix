{ pkgs, lib, config, ... }:

let
  cfg = config.modules.hm.shell.tools;
in
{
  options.modules.hm.shell.tools = {
    enable = lib.mkEnableOption "Enable common shell tools";
  };

  config = lib.mkIf cfg.enable {
    # Install shell tools via home-manager
    home.packages = (with pkgs; [
      tree
    ]);

    programs = {
      ranger.enable = true;
      navi = {
        # Enable navi
        enable = true;
        enableZshIntegration = true;
      };
      fzf = {
        enable = true;
        enableZshIntegration = true;
        tmux.enableShellIntegration = true;
      };
      btop = {

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
  };
}
