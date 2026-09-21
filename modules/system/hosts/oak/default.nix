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
    # server.storage.syncthing = {
    #   enable = true;
    #   dirSync = "/home/${vars.user}";
    #   subDir = "Documents";
    # };
    server.print = {
      enable = true;
      browsed.enable = true;
      shared.enable = true;
      gui.enable = true;
      ensurePrinters = [
        {
          name = "EPSON_ET_1810_Series";
          location = "Home";
          deviceUri = "ipp://192.168.1.14:631/ipp/print";
          model = "everywhere";
          ppdOptions = {
            PageSize = "A4";
          };
        }
        {
          name = "Brother_MFC_J5335DW";
          location = "Home";
          deviceUri = "ipp://192.168.1.25:631/ipp/print";
          model = "everywhere";
        }
      ];

      ensureDefaultPrinter = "EPSON_ET_1810_Series";
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
