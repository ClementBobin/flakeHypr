{ inputs, ... }:
{
  imports = [
    ../../common
    ./plex.nix
    ./sunshine.nix
    ./vfio
  ];

  modules.system = {
    hardware = {
      autologin.enable = false;
      boot.enable = true;
    };
    games.steam.enable = true;

    networks = {
      wol = {
        enable = true;
        interface = "enp7s0";
      };
    };

    # fern specific modules
    fern = {
      plex.enable = true;
      sunshine.enable = true;
      vfio.enable = true;
    };
  };
}
