{ inputs, ... }:
{
  imports = [
    ../../common
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
  };
}
