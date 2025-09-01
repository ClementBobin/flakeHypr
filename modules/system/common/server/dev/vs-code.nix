{
  pkgs,
  lib,
  config,
  vars,
  ...
}:
let
  cfg = config.modules.system.server.dev.vs-code;
in
{
  options.modules.system.server.dev.vs-code = {
    enable = lib.mkEnableOption "Enable VS Code server";

    port = lib.mkOption {
      type = lib.types.port;
      default = 3000;
      description = "Port for the VS Code server to listen on.";
    };
    host = lib.mkOption {
      type = lib.types.str;
      default = "localhost";
      description = "Host for the VS Code server to bind to.";
    };
    extraPackages = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = [];
      description = "Additional packages to install for the VS Code server.";
    };
    extraEnvironment = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      default = {};
      description = "Additional environment variables for the VS Code server.";
    };
    extraArguments = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
      description = "Additional command line arguments for the VS Code server.";
    };
  };

  config = {
    services.code-server = {
      enable = cfg.enable;
      port = cfg.port;
      host = cfg.host;
      extraPackages = cfg.extraPackages;
      extraEnvironment = cfg.extraEnvironment;
      extraArguments = cfg.extraArguments;
      user = "${vars.user}";
    };
  };
}
