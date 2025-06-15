{ inputs, ... }:
{
  imports = [
    ../../common
    ./drivers.nix
    ./plex.nix
    ./sunshine.nix
    ./vfio
    ./wol.nix
  ];

  modules.system = {
    hardware = {
      autologin.enable = false;
      boot.enable = true;
    };
    games.steam.enable = true;

    # fern specific modules
    fern = {
      wol = {
        enable = true;
        interface = "enp7s0";
      };
      drivers.enable = true;
      plex.enable = true;
      sunshine.enable = true;
      vfio.enable = true;
    };
  };
}
