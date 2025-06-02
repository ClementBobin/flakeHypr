{ inputs, ... }:
{
  imports = [
    ../../common
  ];

  modules = {
    nix-garbage = {
      enable = true;
      autoOptimiseStore = true;
    };
    games = {
      enable = true;
      steam.enable = true;
      lutris.enable = true;
    };
    networks = {
      vpn.tailscale.enable = true;
    };
    backup.syncthing = {
      enable = true;
      dirSync = "/home/mirage";
      subDir = "Documents";
    };
    security.antivirus = {
      enable = true;
      engine = "clamav";
      gui.enable = true;
    };
    virtualisation.docker.enable = true;
    dev.php.enable = true;
  };
}
