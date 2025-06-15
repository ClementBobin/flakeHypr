{ vars, ... }:
{
  imports = [
    ../../common
  ];

  modules.system = {
    nix = {
      nix-garbage = {
        enable = true;
        autoOptimiseStore = true;
      };
      polkit.enable = true;
    };
    games.clients = ["steam" "lutris"];
    networks.vpn = ["tailscale"];
    virtualisation.containers.engines = ["docker"];
    backup.syncthing = {
      enable = true;
      dirSync = "/home/${vars.user}";
      subDir = "Documents";
    };
    security = {
      antivirus = {
        engines = ["clamav"];
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
