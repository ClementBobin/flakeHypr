{ pkgs, lib, config, ... }:

let
  cfg = config.modules.hm.dev.languages.kotlin;
in
{
  options.modules.hm.dev.languages.kotlin = {
    enable = lib.mkEnableOption "Enable kotlin development environment";
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [ kotlin ];
  };
}
