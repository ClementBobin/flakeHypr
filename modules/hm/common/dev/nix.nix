{ pkgs, lib, config, ... }:

let
  cfg = config.modules.common.dev.nix;
in
{
  options.modules.common.dev.nix = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable nix development environment";
    };

    installMethod = lib.mkOption {
      type = lib.types.enum [ "hm" "sys" ];
      default = "hm";
      description = "Choose whether to install nix-related tools via home-manager or directly in the environment.";
    };
  };

  config = lib.mkIf cfg.enable {
    # Conditional installation of nix-related tools
    # Check if Home Manager or system-wide installation is preferred
    home.packages = lib.mkIf (cfg.installMethod == "hm") (with pkgs; [
      nixfmt-rfc-style
      nix-direnv
      direnv
      nix-output-monitor
      nix-fast-build
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
