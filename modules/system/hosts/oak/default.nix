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
    virtualisation.containers.engine = ["docker"];
    backup.syncthing = {
      enable = true;
      dirSync = "/home/${vars.user}";
      subDir = "Documents";
    };
    security = {
      antivirus = {
        enable = true;
        engine = "clamav";
        gui.enable = true;
      };
      passwordManager.backend = ["bitwarden"];
    };
    dev = {
      php.enable = true;
      flutter = {
        enable = true;
        withAndroid = true;
      };
    };
    hardware.powersave = {
      enable = true;
      architecture = "amd";
      batteryHealth.enable = true;
      managePowerProfiles = false;
      disk = [ "nvme0n1" ];
      asus.enable = true;
    };
  };
}
