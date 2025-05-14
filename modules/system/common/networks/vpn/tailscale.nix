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
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable tailscale.";
    };
  };

  config = lib.mkIf cfg.enable {
    services.tailscale.enable = true;
  };
}
