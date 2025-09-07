{ pkgs, lib, config, ... }:

let
  cfg = config.modules.hm.multimedia.player;

  # Miru package definition
  miru = pkgs.callPackage ../../../wrapper/hayase.nix { };

  # Map document clients to their packages
  clientsToPackage = with pkgs; {
    mpv = null;
    vlc = vlc;
    stremio = stremio;
    jellyfin = jellyfin-media-player;
    plex = plex-desktop;
    miru = miru;
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
    programs.mpv = lib.mkIf (lib.elem "mpv" cfg.clients) {

      # Enable mpv
      enable = true;

      # Install custom scripts
      scripts = with pkgs.mpvScripts; [
        uosc
      ];

      # Script configuration
      scriptOpts."uosc" = {

        # Style of timeline
        "timeline_style" = "bar";

        # Volume to step when scrolling
        "volume_step" = 5;
      };
    };
  };
}