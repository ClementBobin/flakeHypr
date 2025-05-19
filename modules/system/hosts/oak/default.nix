{ inputs, ... }:
{
  imports = [
    # TODO: oak private modules
    # inputs.richendots-private.nixosModules.oak
    ../../common
  ];

  modules = {
    nix-garbage = {
      enable = true;
      autoOptimiseStore = true;
    };
    games.steam.enable = true;
    networks.vpn.tailscale.enable = true;
    backup.syncthing = {
      enable = true;
      dirSync = "/home/mirage";
      subDir = "Documents";
    };
    virtualisation.docker.enable = true;
    dev.php.enable = true;
  };
}
