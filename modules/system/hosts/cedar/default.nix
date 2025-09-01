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
    };
    networks.vpn = ["tailscale"];
    dev.languages.php.enable = true;
    server = {
      storage = {
        syncthing = {
          enable = true;
          dirSync = "/home/${vars.user}";
          subDir = "Documents";
        };
      };
      dev.vs-code.enable = true;
      media = {
        multimedia = {
          enable = true;
          jellyfin.enable = true;
          sonarr.enable = true;
          radarr.enable = true;
          prowlarr.enable = true;
          bazarr.enable = true;
          jellyseerr.enable = true;
        };
        paperless.enable = true;
        photoprism.enable = true;
      };
      communication = {
        ntfy-sh.enable = true;
        matrix-synapse.enable = true;
        agents = ["qemu"];
      };
      meal.clients = ["mealie"];
    };
  };

  services.portmaster = {
    enable = true;
    devmode.enable = true;
  };
}
