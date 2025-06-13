{ pkgs, inputs, ... }:
{
  imports = [
    ./backup/syncthing.nix

    ./dev/dev.nix
    ./dev/flatpak.nix
    ./dev/flutter.nix
    ./dev/php.nix

    ./games/gamescope.nix
    ./games/games.nix

    ./hardware/autologin.nix
    ./hardware/boot.nix
    ./hardware/powersave.nix

    ./networks/print/print.nix
    ./networks/vpn/tailscale.nix

    ./nix/linux-cachyos.nix
    ./nix/nix-garbage.nix
    ./nix/polkit.nix

    ./security/antivirus.nix
    ./security/password-manager.nix

    ./virtualisation/containers/containers.nix
  ];
}
