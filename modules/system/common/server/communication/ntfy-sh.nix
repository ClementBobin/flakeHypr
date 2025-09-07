{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.modules.system.server.communication.ntfy-sh;
in
{
  options.modules.system.server.communication.ntfy-sh = {
    enable = lib.mkEnableOption "Enable ntfy-sh server";
    baseUrl = lib.mkOption {
      type = lib.types.str;
      default = "http://localhost:2586";
      description = "Base URL for the ntfy-sh server";
    };
    gui.enable = lib.mkEnableOption "Enable ntfy-sh GUI";
    configure-client = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Whether to configure the ntfy client with the server URL";
    };
  };

  config = {
    services.ntfy-sh = {
      enable = cfg.enable;
      settings = {
        base-url = cfg.baseUrl;
        # Add other required settings here
        listen-http = ":2586";
      };
    };

    environment.systemPackages = lib.mkIf cfg.gui.enable (with pkgs; [
      notify-client
    ]);

    home-manager.sharedModules = lib.mkIf cfg.configure-client [
      {
        home.file.".config/ntfy/client.yml".text = ''
          default-host: ${cfg.baseUrl}
        '';
      }
    ];
  };
}