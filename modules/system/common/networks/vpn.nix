{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.modules.system.networks;
in
{
  options.modules.system.networks = {
    vpn = lib.mkOption {
      type = lib.types.listOf (lib.types.enum ["tailscale"]);
      default = [];
      description = "List of VPN services to enable. Currently only 'tailscale' is supported.";
    };
  };

  config = {
    services.tailscale = {
      enable = lib.elem "tailscale" cfg.vpn;
    };
  };
}
