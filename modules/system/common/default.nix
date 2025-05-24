{ pkgs, ... }:
{
  imports = [
    ./backup/syncthing.nix

    ./dev/dev.nix
    ./dev/php.nix

    ./games/gamescope.nix
    ./games/games.nix

    ./hardware/gpu/amd.nix
    ./hardware/autologin.nix
    ./hardware/boot.nix

    ./networks/vpn/tailscale.nix

    ./virtualisation/containers/containers.nix

    ./linux-cachyos.nix

    ./nix-garbage.nix
  ];

  # TODO: move this somewhere?
  # For dolphin udisks2 permission for click mounting disks
  security.polkit.extraConfig = ''
    polkit.addRule(function(action, subject) {
      if (action.id.indexOf("org.freedesktop.udisks2.") == 0 && 
          subject.isInGroup("users")) {
          return polkit.Result.YES;
      }
    });
  '';
}
