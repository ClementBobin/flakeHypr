{ vars, ... }:
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
      print.enable = true;
      vpn.tailscale.enable = true;
    };
    virtualisation.docker.enable = true;
    backup.syncthing = {
      enable = true;
      dirSync = "/home/${vars.user}";
      subDir = "Documents";
    };
    security.antivirus = {
      enable = true;
      engine = "clamav";
      gui.enable = true;
    };
    dev = {
      php.enable = true;
      flutter = {
        enable = true;
        withAndroid = true;
      };
    };
  };
}
