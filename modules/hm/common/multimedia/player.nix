{ pkgs, lib, config, inputs, ... }:

let
  cfg = config.modules.hm.multimedia.player;

  # Map document clients to their packages
  clientsToPackage = with pkgs; {
    mpv = null;
    vlc = vlc;
    jellyfin = jellyfin-media-player;
    jellyfin-client = jellyflix;
    jellyfin-music = finamp;
    jellyfin-music-tui = jellyfin-tui;
    plex = plex-desktop;
    mangayomi = mangayomi;
    ani-cli = ani-cli;
  };

  # Get packages for enabled clients
  enabledPackages = lib.filter (pkg: pkg != null)
    (map (c: clientsToPackage.${c}) cfg.clients);

  # Add jellyfin-rpc if enabled
  finalPackages = enabledPackages ++
    (lib.optional cfg.jellyfin.rpc pkgs.jellyfin-rpc);

in
{
  options.modules.hm.multimedia.player = {
    clients = lib.mkOption {
      type = lib.types.listOf (lib.types.enum (lib.attrNames clientsToPackage));
      default = [];
      description = "List of multimedia player clients to install";
    };

    jellyfin.rpc = lib.mkEnableOption "Enable Jellyfin RPC support";
  };

  config = lib.mkIf (cfg.clients != []) {
    home.packages = finalPackages;

    # Configure mpv media player if it's in the clients list
    programs = {
      mpv = lib.mkIf (lib.elem "mpv" cfg.clients) {
        enable = true;
        scripts = with pkgs.mpvScripts; [
          uosc
        ];
        scriptOpts."uosc" = {
          "timeline_style" = "bar";
          "volume_step" = 5;
        };
      };
    };

    home.shellAliases = {
      # shell alias for ani-cli to anime
      anime = lib.mkIf (lib.elem "ani-cli" cfg.clients) ''ani-cli'';
    };
  };
}