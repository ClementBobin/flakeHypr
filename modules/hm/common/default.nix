{ inputs, lib, config, pkgs, ... }:
let
  cfg = config.modules.hm.nh;
in
{
  imports = [
    ./browser

    ./communication/mail.nix
    ./communication/discord.nix
    ./communication/matrix.nix
    ./communication/teams.nix

    ./dev/environments/containers.nix
    ./dev/environments/editor.nix
    ./dev/languages/dotnet.nix
    ./dev/languages/kotlin.nix
    ./dev/languages/node.nix
    ./dev/languages/python.nix
    ./dev/languages/rust.nix
    ./dev/tools/cli.nix
    ./dev/tools/git-action.nix
    ./dev/tools/gitleaks.nix
    ./dev/tools/nix.nix
    ./dev/tools/prisma.nix

    ./documentation/obsidian.nix
    ./documentation

    ./engine

    ./extra/shader-cache-cleanup.nix
    ./extra/syncthing-ignore.nix

    ./games/games.nix
    ./games/joystick.nix
    ./games/mangohud.nix

    ./multimedia/editing/audio.nix
    ./multimedia/editing/image.nix
    ./multimedia/editing/video.nix
    ./multimedia/management-utility.nix
    ./multimedia/player.nix
    ./multimedia/rambox.nix
    ./multimedia/remote-desktop.nix
    ./multimedia/streaming.nix

    ./network/tunnel.nix

    ./security/burp.nix

    ./shell/disk-usage.nix
    ./shell/tools.nix

    ./utilities/safety/ianny.nix
    ./utilities/api.nix
    ./utilities/app-launcher.nix
    ./utilities/filezilla.nix
    ./utilities/kde-connect.nix
    ./utilities/stacer.nix

    inputs.nix-podman-stacks.homeModules.nps
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
      #home-manager.enable = true;
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