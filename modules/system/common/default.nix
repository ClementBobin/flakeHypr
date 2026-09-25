{ inputs, ... }:
{
  imports = [
    ./dev/languages/android.nix
    ./dev/environments.nix

    ./hardware/powersave
    ./hardware/autologin.nix
    ./hardware/boot.nix

    ./networks/vpn
    ./networks/wol.nix
    ./networks/print.nix

    ./nix
    ./nix/nix-garbage.nix
    ./nix/polkit.nix

    ./security/antivirus.nix
    ./security/password-manager.nix


    ./virtualisation
    ./games.nix
  ];

  nix.settings.experimental-features = [ "nix-command" "flakes" "pipe-operators" ];
}
