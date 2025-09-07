{ config, lib, pkgs, vars, ... }:

with lib;

let
  cfg = config.modules.system.server.print;
in {
  options.modules.system.server.print = {
    enable = mkEnableOption "Enable CUPS (Common Unix Printing System)";
    browsed.enable = mkEnableOption "Enable CUPS Browsed for automatic printer discovery";

    drivers = mkOption {
      type = types.listOf types.package;
      default = [ pkgs.cnijfilter2 ];
      description = ''
        List of printer drivers to use. Defaults to [ pkgs.cnijfilter2 ], which
        is an unfree package for Canon printers.
      '';
    };
    listenAddresses = mkOption {
      type = types.listOf types.str;
      default = [ "localhost:631" ];
      description = ''
        List of addresses to listen on for incoming print jobs. Defaults to
        [ "localhost:631" ].
      '';
    };
    allowFrom = mkOption {
      type = types.listOf types.str;
      default = [ "localhost" ];
      description = ''
        List of addresses allowed to send print jobs. Defaults to [ "localhost" ].
        You can add more addresses or networks as needed.
      '';
    };
    logLevel = mkOption {
      type = types.str;
      default = "info";
      description = ''
        Log level for CUPS. Can be set to "debug", "info", "warn", or "error".
        Defaults to "info".
      '';
    };
    openFirewall = mkOption {
      type = types.bool;
      default = true;
      description = ''
        Whether to open the firewall for CUPS. If enabled, it will allow incoming
        connections on port 631 (the default CUPS port).
      '';
    };
    webInterface = mkOption {
      type = types.bool;
      default = true;
      description = ''
        Whether to enable the CUPS web interface. If enabled, you can access it
        at http://localhost:631.
      '';
    };
    gui = {
      enable = mkEnableOption "Enable GUI tools for managing printers";

      packages = mkOption {
        type = types.listOf types.package;
        default = [ pkgs.system-config-printer ];
        description = ''
          List of GUI tools for managing printers. Defaults to
          [ pkgs.system-config-printer ].
        '';
      };
    };
  };

  config = {
    services.printing = {
      enable = cfg.enable;
      drivers = lib.mkIf cfg.enable cfg.drivers;
      listenAddresses = cfg.listenAddresses;
      allowFrom = cfg.allowFrom;
      logLevel = cfg.logLevel;
      openFirewall = cfg.openFirewall;
      webInterface = cfg.webInterface;
    };

    services.avahi.enable = cfg.browsed.enable;

    users.users.${vars.user}.extraGroups = [ "lp" "lpadmin" ];

    environment.systemPackages = lib.mkIf cfg.gui.enable cfg.gui.packages;
  };
}