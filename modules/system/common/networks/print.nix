{ config, lib, pkgs-unstable, vars, ... }:

with lib;

let
  cfg = config.modules.system.server.print;
in {
  options.modules.system.server.print = {
    enable = mkEnableOption "Enable CUPS (Common Unix Printing System)";
    browsed.enable = mkEnableOption "Enable CUPS Browsed for automatic printer discovery";
    shared.enable = mkEnableOption "Enable printer sharing over the network";

    # Define custom options for declarative printers
    ensurePrinters = mkOption {
      type = types.listOf types.attrs;
      default = [];
      example = literalExpression ''
        [
          {
            name = "EPSON_ET_1810_Series";
            location = "Home";
            deviceUri = "ipp://192.168.1.14:631/ipp/print";
            model = "everywhere";
          }
        ]
      '';
      description = "List of printers to ensure are configured in CUPS.";
    };

    ensureDefaultPrinter = mkOption {
      type = types.nullOr types.str;
      default = null;
      example = "EPSON_ET_1810_Series";
      description = "The default system printer.";
    };

    drivers = mkOption {
      type = types.listOf types.package;
      default = [ pkgs-unstable.epson-escpr2 ];
      example = literalExpression ''
        with pkgs-unstable; [
          cnijfilter2
          gutenprint
          hplip
          samsung-unified-linux-driver
        ]
      '';
      description = ''
        List of printer drivers to use. Defaults to [ pkgs-unstable.cnijfilter2 ], which
        is an unfree package for Canon printers.
      '';
    };
    listenAddresses = mkOption {
      type = types.listOf types.str;
      default = [ "localhost:631" ];
      example = [ "*:631" "192.168.1.100:631" ];
      description = mdDoc ''
        Network addresses and ports where CUPS should listen for connections.
        
        Format: [ "address:port" ] or [ "port" ] for all interfaces
        Examples:
        - ["localhost:631"]: Listen only on localhost (default, most secure)
        - ["*:631"]: Listen on all network interfaces
        - ["192.168.1.100:631"]: Listen on specific IP address
        - ["631"]: Listen on all interfaces (legacy format)
        
        For network printing, you may want to use ["*:631"] to allow
        connections from other computers on your network.
      '';
    };
    allowFrom = mkOption {
      type = types.listOf types.str;
      default = [ "localhost" ];
      example = [ "localhost" "192.168.1.0/24" "*.example.com" ];
      description = ''
        List of addresses allowed to send print jobs. Defaults to [ "localhost" ].
        You can add more addresses or networks as needed.
      '';
    };
    logLevel = mkOption {
      type = types.enum [ "debug" "info" "warn" "error" "fatal" "none" ];
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
        default = [ pkgs-unstable.system-config-printer ];
        example = literalExpression ''
          with pkgs-unstable; [
            system-config-printer
            print-manager
            gtklp
          ]
        '';
        description = ''
          List of GUI tools for managing printers. Defaults to
          [ pkgs-unstable.system-config-printer ].
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
      browsing = cfg.browsed.enable;
      defaultShared = cfg.shared.enable;
    };

    hardware.printers = {
      ensurePrinters = cfg.ensurePrinters;
      ensureDefaultPrinter = cfg.ensureDefaultPrinter;
    };

    services.avahi = {
      enable = cfg.browsed.enable;
      nssmdns4 = cfg.browsed.enable;
    };

    users.users.${vars.user}.extraGroups = [ "lp" "lpadmin" ];

    environment.systemPackages = lib.mkIf cfg.gui.enable cfg.gui.packages;
  };
}