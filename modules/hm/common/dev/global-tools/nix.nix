{ pkgs, lib, config, ... }:

let
  cfg = config.modules.common.dev.global-tools.nix;
in
{
  options.modules.common.dev.global-tools.nix = {
    enable = lib.mkEnableOption "Enable Nix development environment";
  };

  config = lib.mkIf cfg.enable {
    # Conditional installation of nix-related tools
    # Check if Home Manager or system-wide installation is preferred
    home.packages = (with pkgs; [
      nixfmt-rfc-style
      nix-direnv
      direnv
      nix-output-monitor
      nix-fast-build
      act
    ]);

    # Programs configuration should be inside the config block
    programs.direnv = {
      enable = true;
      silent = true;
      nix-direnv.enable = true;
      enableZshIntegration = true;
    };

    programs.zsh = {
      initExtra = pkgs.lib.mkAfter ''
        source ${pkgs.nix-index}/etc/profile.d/command-not-found.sh
      '';
    };
  };
}
