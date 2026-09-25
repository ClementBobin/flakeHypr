{ pkgs, lib, config, ... }:

let
  cfg = config.modules.hm.shell.tools;
in
{
  options.modules.hm.shell.tools = {
    enable = lib.mkEnableOption "Enable common shell tools";
    shellAliases = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      default = {};
      description = "Shell aliases to set up";
      example = { ll = "ls -la"; gs = "git status"; };
    };
  };

  config = lib.mkIf cfg.enable {
    # Install shell tools via home-manager
    home = {
      packages = (with pkgs; [
        tree
      ]);
      shellAliases = cfg.shellAliases;
    };

    programs = {
      ranger.enable = lib.mkDefault true;
      navi = {
        # Enable navi
        enable = lib.mkDefault true;
        enableZshIntegration = lib.mkDefault true;
      };
      fzf = {
        enable = lib.mkDefault true;
        enableZshIntegration = lib.mkDefault true;
      };
      btop = {

        # Enable btop
        enable = lib.mkDefault true;

        # Configuration for btop
        settings = {

          # Use default terminal background
          theme_background = lib.mkDefault false;

          # Use vim keys
          vim_keys = lib.mkDefault true;

          # Organise processes as a tree by default
          proc_tree = lib.mkDefault true;
        };
      };
    };
  };
}
