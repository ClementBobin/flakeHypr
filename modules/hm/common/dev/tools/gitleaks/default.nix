{ pkgs, lib, config, ... }:

let
  cfg = config.modules.hm.dev.tools.gitleaks;

  # Get the directory where this file is located
  moduleDir = toString ./.;
in
{
  options.modules.hm.dev.tools.gitleaks = {
    enable = lib.mkEnableOption "Enable Gitleaks for detecting secrets in git repositories";
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs.gitleaks ];

    programs.git.enable = true;

    programs.git.settings = {
      core.hooksPath = "${config.xdg.configHome}/.git-config/.git-hooks";
    };

    # Copy gitleaks config file
    home.file.".git-config/.gitleaks.toml".source =
      "${moduleDir}/.gitleaks.toml";

    # Copy pre-commit hook
    home.file.".git-config/.git-hooks/pre-commit" = {
      source = "${moduleDir}/pre-commit-hook.sh";
      executable = true;
    };
  };
}