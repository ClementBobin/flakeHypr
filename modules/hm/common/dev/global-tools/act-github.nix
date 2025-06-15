{ pkgs, lib, config, ... }:

let
  cfg = config.modules.hm.dev.global-tools.act-github;
in
{
  options.modules.hm.dev.global-tools.act-github = {
    enable = lib.mkEnableOption "Enable act for running GitHub Actions locally";
  };

  config = lib.mkIf cfg.enable {
    home.packages = (with pkgs; [
      act
    ]);
  };
}
