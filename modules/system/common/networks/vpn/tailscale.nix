{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.modules.system.networks.vpn.tailscale;
in
{
  options.modules.system.networks.vpn.tailscale = {
    enable = lib.mkEnableOption "Enable Tailscale VPN support";
  };

  config = lib.mkIf cfg.enable {
    services.tailscale = {
      enable = true;
    };
  };
}
