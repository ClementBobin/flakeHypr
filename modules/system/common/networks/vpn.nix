{ lib, config, pkgs, vars, ... }:

let
  inherit (lib) mkEnableOption mkOption types;
  cfg = config.modules.system.networks;

  # ── Script derivations ────────────────────────────────────────────────────

  wireguard-script = pkgs.writeShellScript "wireguard-vpn"
    (builtins.readFile ./wireguard-vpn.sh);

  openfortivpn-script = pkgs.writeShellScript "openfortivpn-vpn"
    (builtins.readFile ./openfortivpn.sh);

  # ── Unified `vpn` dispatcher ──────────────────────────────────────────────
  #
  #   vpn wg  [up|down|status|config|edit|menu]
  #   vpn of  [up|down|status|config|edit|menu]
  #   vpn     → interactive picker then delegates
  #
  vpn-tool = pkgs.writeShellScriptBin "vpn" ''
    usage() {
      echo "VPN Manager"
      echo "Usage: vpn <backend> [command]"
      echo ""
      echo "Backends:"
      echo "  wg, wireguard      WireGuard (wg*.conf in ~/vpn)"
      echo "  of, openforti      OpenFortiVPN (vpn-config* in ~/vpn)"
      echo ""
      echo "Commands (same for both backends):"
      echo "  up      Start VPN"
      echo "  down    Stop VPN"
      echo "  status  Show status"
      echo "  config  Show configuration (keys masked)"
      echo "  edit    Edit config files (TUI picker)"
      echo "  menu    Interactive TUI menu (default)"
    }

    case "''${1:-}" in
      wg|wireguard)
        shift
        exec ${wireguard-script} "''${@}"
        ;;
      of|openforti|openfortivpn)
        shift
        exec ${openfortivpn-script} "''${@}"
        ;;
      -h|--help|help)
        usage
        ;;
      "")
        # No argument: present a backend picker then hand off
        echo ""
        echo "Select VPN backend:"
        echo "  1) WireGuard"
        echo "  2) OpenFortiVPN"
        echo ""
        read -rp "Choice [1/2]: " choice
        case "$choice" in
          1) exec ${wireguard-script} ;;
          2) exec ${openfortivpn-script} ;;
          *) echo "Invalid choice"; exit 1 ;;
        esac
        ;;
      *)
        echo "Unknown backend: $1"
        echo ""
        usage
        exit 1
        ;;
    esac
  '';

in {

  # ── Options ─────────────────────────────────────────────────────────────────

  options.modules.system.networks = {

    vpn = mkOption {
      type = types.listOf (types.enum [ "tailscale" "wireguard" "openfortivpn" ]);
      default = [];
      description = "List of VPN services to enable.";
      example = [ "wireguard" "openfortivpn" ];
    };

    # ── Tailscale ────────────────────────────────────────────────────────────

    tailscale = {
      disable-ssh     = mkEnableOption "Disable SSH access over VPN";
      disable-op-user = mkEnableOption "Disable operator user for VPN services";
    };

    # ── Shared ───────────────────────────────────────────────────────────────

    configDir = mkOption {
      type = types.str;
      default = "$HOME/vpn";
      description = ''
        Directory containing VPN configuration files.
          WireGuard:    wg*.conf
          OpenFortiVPN: vpn-config* or openforti*.conf
      '';
      example = "/home/alice/vpn";
    };

    # ── WireGuard ────────────────────────────────────────────────────────────

    wireguard = {
      autoLoadKernelModule = mkOption {
        type = types.bool;
        default = true;
        description = ''
          Load the WireGuard kernel module at boot.
          Required for wg-quick to work without a nix-shell wrapper.
        '';
      };
    };

    # ── OpenFortiVPN ─────────────────────────────────────────────────────────

    openfortivpn = {
      defaultConfigFile = mkOption {
        type = types.str;
        default = "vpn-config";
        description = ''
          Default config filename inside configDir used when only one
          config exists (no TUI picker shown).
        '';
        example = "work-vpn.conf";
      };
    };
  };

  # ── Config ──────────────────────────────────────────────────────────────────

  config = let
    tailscaleEnabled    = lib.elem "tailscale"    cfg.vpn;
    wireguardEnabled    = lib.elem "wireguard"    cfg.vpn;
    openfortivpnEnabled = lib.elem "openfortivpn" cfg.vpn;
    anyVpnTool          = wireguardEnabled || openfortivpnEnabled;

    tsCfg = {
      ssh      = !cfg.tailscale.disable-ssh;
      operator = if cfg.tailscale.disable-op-user then null else vars.user;
    };
  in lib.mkMerge [

    # ── Tailscale ─────────────────────────────────────────────────────────────

    (lib.mkIf tailscaleEnabled {
      services.tailscale = {
        enable = true;
        extraUpFlags = []
          ++ lib.optional tsCfg.ssh "--ssh"
          ++ lib.optional (tsCfg.operator != null) "--operator=${tsCfg.operator}";
      };
    })

    # ── Shared VPN tools (vpn dispatcher) ─────────────────────────────────────

    (lib.mkIf anyVpnTool {
      environment.systemPackages = [ vpn-tool ];
    })

    # ── WireGuard ─────────────────────────────────────────────────────────────

    (lib.mkIf wireguardEnabled {
      environment.systemPackages = [ pkgs.wireguard-tools ];

      boot.kernelModules = lib.mkIf cfg.wireguard.autoLoadKernelModule [ "wireguard" ];

      environment.etc."vpn-scripts/wireguard-vpn.sh" = {
        source = wireguard-script;
        mode   = "0755";
      };

      # security.sudo.extraRules = [{
      #   groups   = [ "wheel" ];
      #   commands = [
      #     { command = "${pkgs.wireguard-tools}/bin/wg";       options = [ "NOPASSWD" ]; }
      #     { command = "${pkgs.wireguard-tools}/bin/wg-quick"; options = [ "NOPASSWD" ]; }
      #   ];
      # }];
    })

    # ── OpenFortiVPN ──────────────────────────────────────────────────────────

    (lib.mkIf openfortivpnEnabled {
      environment.systemPackages = [ pkgs.openfortivpn ];

      environment.etc."vpn-scripts/openfortivpn-vpn.sh" = {
        source = openfortivpn-script;
        mode   = "0755";
      };

      # security.sudo.extraRules = [{
      #   groups   = [ "wheel" ];
      #   commands = [
      #     { command = "${pkgs.openfortivpn}/bin/openfortivpn"; options = [ "NOPASSWD" ]; }
      #   ];
      # }];
    })

  ];
}
