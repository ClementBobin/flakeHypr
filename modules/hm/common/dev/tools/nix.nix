{ pkgs, lib, config, ... }:

let
  cfg = config.modules.hm.dev.tools.nix;
in
{
  options.modules.hm.dev.tools.nix = {
    enable = lib.mkEnableOption "Enable Nix development environment";
  };

  config = lib.mkIf cfg.enable {
    # Install nix-related tools via home-manager
    home.packages = (with pkgs; [
      nixfmt-rfc-style
      nix-direnv
      direnv
      nix-output-monitor
      nix-fast-build
      openssl
    ]);

    # Programs configuration should be inside the config block
    programs.direnv = {
      enable = true;
      silent = true;
      nix-direnv.enable = true;
      enableZshIntegration = true;
    };

    programs.zsh = {
      initExtra = lib.mkAfter ''
        source ${pkgs.nix-index}/etc/profile.d/command-not-found.sh
      '';
    };
  };
}
