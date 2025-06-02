{ pkgs, lib, config, ... }:

let
  cfg = config.modules.common.dev.global-tools.act-github;
in
{
  options.modules.common.dev.global-tools.act-github = {
    enable = lib.mkEnableOption "Enable Nix development environment";
  };

  config = lib.mkIf cfg.enable {
    # Conditional installation of act-related tools
    # Check if Home Manager or system-wide installation is preferred
    home.packages = (with pkgs; [
      act
    ]);
  };
}
