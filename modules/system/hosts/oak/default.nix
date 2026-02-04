{ vars, ... }:
{
  imports = [
    ../../common
    ../../../wrapper/safing/module.nix
  ];

  modules.system = {
    nix = {
      nix-garbage = {
        enable = true;
        autoOptimiseStore = true;
      };
      polkit.enable = true;
    };
    games = {
      clients = ["steam"];
      # gamemode.enable = true;
    };
    networks.vpn = ["tailscale"];
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

  services.portmaster = {
    enable = false;
    devmode.enable = false;
  };
}
