{ inputs, ... }:
{
  imports = [
    ./dev/languages/flutter.nix
    ./dev/languages/php.nix
    ./dev/tools/flatpak.nix
    ./dev/environments.nix

    ./hardware/powersave
    ./hardware/autologin.nix
    ./hardware/boot.nix

    ./networks/vpn.nix
    ./networks/wol.nix

    ./nix
    ./nix/nix-garbage.nix
    ./nix/polkit.nix

    ./security/antivirus.nix
    ./security/password-manager.nix

    ./server/communication/agents.nix
    ./server/communication/deskflow.nix
    ./server/communication/matrix.nix
    ./server/communication/ntfy-sh.nix
    ./server/dev/vs-code.nix
    ./server/games/sunshine.nix
    ./server/media/multimedia.nix
    ./server/media/paperless.nix
    ./server/media/photoprism.nix
    ./server/password-manager/vaultwarden.nix
    ./server/storage/forgejo.nix
    ./server/storage/syncthing.nix
    ./server/meal.nix
    ./server/print.nix

    ./virtualisation
    ./virtualisation/ollama.nix

    ./games.nix
  ];

  nix.settings.experimental-features = [ "nix-command" "flakes" "pipe-operators" ];
}
