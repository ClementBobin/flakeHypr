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
      gamemode.enable = true;
    };
    networks.vpn = ["tailscale"];
    server.storage.syncthing = {
      enable = true;
      dirSync = "/home/${vars.user}";
      subDir = "Documents";
    };
    security.passwordManager.backend = ["bitwarden"];
    hardware.powersave = {
      enable = true;
      architecture = "intel";
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
      disk = [ ];
    };
  };

#  services.portmaster = {
#    enable = true;
#    devmode.enable = true;
#  };
}
