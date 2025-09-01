{ pkgs, lib, config, ... }:

let
  cfg = config.modules.hm.dev.tools.gitleaks;
in
{
  options.modules.hm.dev.tools = {
    gitleaks.enable = lib.mkEnableOption "Enable Gitleaks for detecting secrets in git repositories";
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs.gitleaks ];
  };
}