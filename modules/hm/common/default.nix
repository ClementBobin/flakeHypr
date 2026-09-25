{ lib, config, ... }:
let
  cfg = config.modules.hm.nh;
in
{
  imports = [
    ./communication/mail.nix
    ./communication/teams.nix

    ./dev/environments/containers.nix
    ./dev/environments/editor.nix
    ./dev/languages/dotnet.nix
    ./dev/languages/node.nix
    ./dev/languages/php.nix
    ./dev/languages/python.nix
    ./dev/tools/opencode.nix
    ./dev/tools/git-action.nix
    ./dev/tools/gitleaks
    ./dev/tools/nix.nix
    ./dev/tools/prisma.nix

    ./documentation/obsidian.nix
    ./documentation

    ./extra/shader-cache-cleanup.nix
    ./extra/syncthing-ignore.nix

    ./games/games.nix
    ./games/joystick.nix
    ./games/mangohud.nix

    ./multimedia/editing/image.nix
    ./multimedia/editing/video.nix
    ./multimedia/player.nix
    ./multimedia/remote-desktop.nix
    ./multimedia/streaming.nix
    ./multimedia/wallpaper-engine.nix

    ./shell/disk-usage.nix
    ./shell/tools.nix

    ./utilities/api.nix
    ./utilities/time-tracker.nix
  ];

  options.modules.hm.nh = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable Home Manager configuration for this host";
    };
    clean.extraArgs = lib.mkOption {
      type = lib.types.str;
      default = "--keep-since 4d --keep 3";
      description = "Extra arguments for NH clean up";
    };
    flakePath = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Absolute path to the flake, or null";
    };
  };

  config = {
    programs = {
      nh = {
        enable = cfg.enable;
        clean = {
          enable = cfg.enable;
          extraArgs = cfg.clean.extraArgs;
        };
        flake = cfg.flakePath;
      };
    };
  };
}