{ vars, pkgs, ... }:
{
  imports = [
    ../../common
    #../../../wrapper/safing/module.nix
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
      gamemode.enable = true;
    };
    networks.vpn = ["tailscale"];
    server.storage.syncthing = {
      enable = true;
      dirSync = "/home/${vars.user}";
      subDir = "Documents";
    };
    server.print = {
      enable = true;
      browsed.enable = true;
      drivers = [ pkgs.epson-escpr2 pkgs.hplip ];
      gui.enable = true;
    };
    security.passwordManager.backend = ["bitwarden"];
    hardware.powersave = {
      enable = true;
      architecture = "intel";
      enableBenchmarkTools = true;
      forcePerfOnAC = true;
      batteryHealth = {
        enable = true;
        chargeThresholds = {
          start = 55;
          stop = 60;
        };
      };
      managePowerProfiles = false;
      disk = [ "nvme0n1" ];
    };
  };

#  services.portmaster = {
#    enable = true;
#    devmode.enable = true;
#  };
}
