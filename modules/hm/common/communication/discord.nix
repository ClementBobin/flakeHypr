{ pkgs, lib, config, ... }:

let
  cfg = config.modules.hm.communication.discord;

  # Map Discord clients to their packages
  clientsToPackage = with pkgs; {
    discord = discord;
    discordo = discordo;
    discord-sh = discord-sh;
    discord-ptb = discord-ptb;
    discord-canary = discord-canary;
    discord-development = discord-development;
    cordless = cordless;
  };

  # Map overlay names to their packages
  overlaysToPackage = with pkgs; {
    "discover-overlay" = discover-overlay;
    overlayed = overlayed;
  };

  # Get packages for enabled clients
  clientPackages = map (client: clientsToPackage.${client}) cfg.clients;

  # Get overlay packages
  overlayPackages = map (overlay: overlaysToPackage.${overlay}) cfg.overlays;

  # RPC package
  rpcPackage = lib.optional cfg.rpc.enable pkgs.discord-rpc;

in
{
  options.modules.hm.communication.discord = {
    clients = lib.mkOption {
      type = lib.types.listOf (lib.types.enum (lib.attrNames clientsToPackage));
      default = [];
      description = "List of Discord clients to install";
    };

    overlays = lib.mkOption {
      type = lib.types.listOf (lib.types.enum (lib.attrNames overlaysToPackage));
      default = [];
      description = "List of Discord overlays to install";
    };

    rpc.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether to enable Discord Rich Presence support";
    };
  };

  config = lib.mkIf (cfg.clients != [] || cfg.overlays != [] || cfg.rpc.enable) {
    home.packages = clientPackages ++ overlayPackages ++ rpcPackage;
  };
}