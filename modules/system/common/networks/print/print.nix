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
    drivers = mkOption {
      type = types.listOf types.package;
      default = [ pkgs.cnijfilter2 ];
      description = ''
        List of printer drivers to use. Defaults to [ pkgs.cnijfilter2 ], which
        is an unfree package for Canon printers.
      '';
    };
  };

  config = mkIf cfg.enable {
    services.printing.enable = cfg.cups.enable;
    services.printing.drivers = lib.mkIf cfg.cups.enable cfg.drivers;
  };
}