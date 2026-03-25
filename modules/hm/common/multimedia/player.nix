{ pkgs, lib, config, inputs, ... }:

let
  cfg = config.modules.hm.multimedia.player;

  spicePkgs = inputs.spicetify-nix.legacyPackages.${pkgs.stdenv.system};

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
    spicetify = null;
  };

  # Get packages for enabled clients
  enabledPackages = lib.filter (pkg: pkg != null)
    (map (c: clientsToPackage.${c}) cfg.clients);

  # Add jellyfin-rpc if enabled
  finalPackages = enabledPackages ++
    (lib.optional cfg.jellyfin.rpc pkgs.jellyfin-rpc);

in
{
  imports = [
    inputs.spicetify-nix.homeManagerModules.spicetify
  ];

  options.modules.hm.multimedia.player = {
    clients = lib.mkOption {
      type = lib.types.listOf (lib.types.enum (lib.attrNames clientsToPackage));
      default = [];
      description = "List of multimedia player clients to install";
    };

    spicetify = {
      extensions = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [
          "shuffle"
          "autoSkipExplicit"
          "autoVolume"
          "adblock"
          "coverAmbience"
        ];
        description = "List of Spicetify extension names to enable.";
      };
      apps = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [
          "marketplace"
          "ncsVisualizer"
        ];
        description = "List of Spicetify apps to enable.";
      };
      theme = lib.mkOption {
        type = lib.types.str;
        default = "text";
        description = "Spicetify theme to use.";
      };
      colorScheme = lib.mkOption {
        type = lib.types.str;
        default = "Spotify";
        description = "Spicetify color scheme to use.";
      };
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

      spicetify = lib.mkIf (lib.elem "spicetify" cfg.clients) {
        enable = true;
        enabledExtensions = with spicePkgs.extensions; [
          # Convert extension names to actual extension paths/derivations
        ] ++ (map (ext: spicePkgs.extensions.${ext}) cfg.spicetify.extensions);
        theme = spicePkgs.themes.${cfg.spicetify.theme};
        colorScheme = cfg.spicetify.colorScheme;
        enabledCustomApps = with spicePkgs.apps; [
          # Convert app names to actual app paths/derivations
        ] ++ (map (app: spicePkgs.apps.${app}) cfg.spicetify.apps);
      };
    };

    home.shellAliases = {
      # shell alias for ani-cli to anime
      anime = lib.mkIf (lib.elem "ani-cli" cfg.clients) ''ani-cli'';
    };
  };
}