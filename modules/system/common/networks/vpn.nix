{ lib, config, vars, ... }:

let
  inherit (lib) mkEnableOption mkOption types;
  cfg = config.modules.system.networks;
in {
  options.modules.system.networks = {
    vpn = mkOption {
      type = types.listOf (types.enum [ "tailscale" ]);
      default = [];
      description = "List of VPN services to enable. Currently only 'tailscale' is supported.";
    };

    disable-ssh = mkEnableOption "Disable SSH access over VPN";

    disable-op-user = mkEnableOption "Disable operator user for VPN services";
  };

  config = let
    tailscaleEnabled = lib.elem "tailscale" cfg.vpn;
    tsCfg = {
      ssh = !cfg.disable-ssh;
      operator = if cfg.disable-op-user then null else vars.user;
    };
  in lib.mkIf tailscaleEnabled {
    services.tailscale = {
      enable = true;
      extraUpFlags = []
        ++ lib.optional tsCfg.ssh "--ssh"
        ++ lib.optional (tsCfg.operator != null) "--operator=${tsCfg.operator}";
    };
  };
}