{ inputs, ... }:
{
  imports = [
    # TODO: oak private modules
    # inputs.richendots-private.nixosModules.oak
    ../../common
  ];

  modules = {
    games.steam.enable = true;
    networks.vpn.tailscale.enable = true;
    backup.syncthing.enable = true;
    virtualisation.docker.enable = true;
    dev.php.enable = true;
  };
}
