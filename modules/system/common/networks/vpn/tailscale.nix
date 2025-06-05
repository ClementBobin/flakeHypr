{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.modules.networks.vpn.tailscale;
in
{
  options.modules.networks.vpn.tailscale = {
    enable = lib.mkEnableOption "Enable Tailscale VPN support";
  };

  config = lib.mkIf cfg.enable {
    services.tailscale = {
      enable = true;
    };
  };
}
