{ vars, ... }:
{
  imports = [
    ../../common
  ];

  modules.system = {
    nix = {
      polkit.enable = true;
    };
    games = {
      clients = ["steam"];
      steamtinkerlauncher = true;
      #gamemode.enable = true;
    };
    virtualisation.wine.enable = true;
    networks.vpn = ["tailscale" "openfortivpn"];
    # virtualisation.enable = true;
    server.storage.syncthing = {
      enable = true;
      dirSync = "/home/${vars.user}";
      subDir = "Documents";
    };
    server.print = {
      enable = true;
      browsed.enable = true;
      gui.enable = true;
    };
    security.passwordManager.backend = ["bitwarden"];
    dev.languages.android.enable = true;
    hardware.powersave = {
      enable = true;
      architecture = "amd";
      enableBenchmarkTools = true;
      forcePerfOnAC = false;
      batteryHealth = {
        enable = true;
        chargeThresholds = {
          start = 55;
          stop = 60;
        };
      };
      managePowerProfiles = false;
      disk = [ "nvme0n1" "nvme1n1" ];
      asus.enable = true;
    };
  };
}
