{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.modules.networks.print;
in {
  options.modules.networks.print = {
    enable = mkEnableOption "Print services";
    cups.enable = mkOption {
      type = types.bool;
      default = true;
      description = "Enable CUPS (Common Unix Printing System)";
    };
  };

  config = mkIf cfg.enable {
    services.printing = {
      enable = cfg.cups.enable;
      drivers = [ pkgs.cnijfilter2 ];
    };
  };
}