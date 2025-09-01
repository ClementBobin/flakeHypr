{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.portmaster;
  portmasterPkg = pkgs.callPackage ./package.nix {};
in {
  options.services.portmaster = {
    enable = mkEnableOption "Portmaster application firewall";

    package = mkOption {
      type = types.package;
      default = portmasterPkg;
      description = "Portmaster package to use";
    };

    devmode.enable = mkOption {
      type = types.bool;
      default = false;
      description = "Enable development mode (makes UI available at 127.0.0.1:817)";
    };

    extraArgs = mkOption {
      type = types.listOf types.str;
      default = [];
      description = "Extra command-line arguments for portmaster-core";
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [ cfg.package ];

    boot.kernelModules = [ "netfilter_queue" ];

    systemd.tmpfiles.rules = [
      "d /var/lib/portmaster 0755 root root -"
      "d /var/lib/portmaster/logs 0755 root root -"
      "d /var/lib/portmaster/download_binaries 0755 root root -"
      "d /var/lib/portmaster/updates 0755 root root -"
      "d /var/lib/portmaster/databases 0755 root root -"
      "d /var/lib/portmaster/databases/icons 0755 root root -"
      "d /var/lib/portmaster/config 0755 root root -"
      "d /var/lib/portmaster/intel 0755 root root -"
      "d /usr/lib/portmaster 0755 root root -"
      "L+ /usr/lib/portmaster/portmaster-core - - - - ${cfg.package}/usr/lib/portmaster/portmaster-core"
      "L+ /usr/lib/portmaster/portmaster - - - - ${cfg.package}/usr/lib/portmaster/portmaster"
      "L+ /usr/lib/portmaster/portmaster.zip - - - - ${cfg.package}/usr/lib/portmaster/portmaster.zip"
      "L+ /usr/lib/portmaster/assets.zip - - - - ${cfg.package}/usr/lib/portmaster/assets.zip"
    ];

    systemd.services.portmaster = {
      description = "Portmaster by Safing";
      documentation = [ "https://safing.io" "https://docs.safing.io" ];
      before = [ "nss-lookup.target" "network.target" "shutdown.target" ];
      after = [ "systemd-networkd.service" "systemd-tmpfiles-setup.service" ];
      conflicts = [ "shutdown.target" "firewalld.service" ];
      wants = [ "nss-lookup.target" ];
      wantedBy = [ "multi-user.target" ];
      requires = [ "systemd-tmpfiles-setup.service" ];

      preStart = ''
        if [ ! -e "/usr/lib/portmaster/portmaster-core" ]; then
          echo "Creating portmaster symlinks manually..."
          mkdir -p /usr/lib/portmaster
          ln -sf ${cfg.package}/usr/lib/portmaster/portmaster-core /usr/lib/portmaster/portmaster-core
          ln -sf ${cfg.package}/usr/lib/portmaster/portmaster /usr/lib/portmaster/portmaster
          ln -sf ${cfg.package}/usr/lib/portmaster/portmaster.zip /usr/lib/portmaster/portmaster.zip
          ln -sf ${cfg.package}/usr/lib/portmaster/assets.zip /usr/lib/portmaster/assets.zip
        fi

        if [ ! -f "/var/lib/portmaster/intel/index.json" ]; then
          echo "Copying initial intel data..."
          if [ -d "${cfg.package}/var/lib/portmaster/intel" ]; then
            cp -r ${cfg.package}/var/lib/portmaster/intel/* /var/lib/portmaster/intel/ || true
          else
            echo "Warning: No intel data found in package"
          fi
        fi
      '';

      script = let
        baseArgs = [
          "/usr/lib/portmaster/portmaster-core"
          "--log-dir=/var/lib/portmaster/logs"
        ];
        devmodeArgs = lib.optional cfg.devmode.enable "--devmode";
        allArgs = baseArgs ++ devmodeArgs ++ [ "--" ] ++ cfg.extraArgs;
      in lib.concatStringsSep " " allArgs;

      postStop = ''
        /usr/lib/portmaster/portmaster-core recover-iptables || echo "Iptables cleanup completed"
      '';

      serviceConfig = {
        Type = "simple";
        Restart = "on-failure";
        RestartSec = "10";
        RestartPreventExitStatus = "24";
        User = "root";
        Group = "root";
        LockPersonality = true;
        MemoryDenyWriteExecute = true;
        MemoryLow = "2G";
        NoNewPrivileges = true;
        PrivateTmp = true;
        PIDFile = "/var/lib/portmaster/core-lock.pid";
        StateDirectory = "portmaster";
        WorkingDirectory = "/var/lib/portmaster";
        ProtectSystem = true;
        ReadWritePaths = [ "/usr/lib/portmaster" "/var/lib/portmaster" ];
        ProtectHome = "read-only";
        ProtectKernelTunables = true;
        ProtectKernelLogs = true;
        ProtectControlGroups = true;
        PrivateDevices = true;
        RestrictNamespaces = true;
        AmbientCapabilities = [
          "cap_chown"
          "cap_kill"
          "cap_net_admin"
          "cap_net_bind_service"
          "cap_net_broadcast"
          "cap_net_raw"
          "cap_sys_module"
          "cap_sys_ptrace"
          "cap_dac_override"
          "cap_fowner"
          "cap_fsetid"
          "cap_sys_resource"
          "cap_bpf"
          "cap_perfmon"
        ];
        CapabilityBoundingSet = [
          "cap_chown"
          "cap_kill"
          "cap_net_admin"
          "cap_net_bind_service"
          "cap_net_broadcast"
          "cap_net_raw"
          "cap_sys_module"
          "cap_sys_ptrace"
          "cap_dac_override"
          "cap_fowner"
          "cap_fsetid"
          "cap_sys_resource"
          "cap_bpf"
          "cap_perfmon"
        ];
        RestrictAddressFamilies =
          [ "AF_UNIX" "AF_NETLINK" "AF_INET" "AF_INET6" ];
        Environment = [ "LOGLEVEL=info" "PORTMASTER_ARGS=" ];
        EnvironmentFile = [ "-/etc/default/portmaster" ];
      };
    };

    networking.firewall.allowedTCPPorts = lib.optional cfg.devmode.enable 817;

    boot.kernel.sysctl = {
      "net.ipv4.ip_forward" = 1;
      "net.ipv6.conf.all.forwarding" = 1;
    };
  };
}