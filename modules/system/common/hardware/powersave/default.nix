{ config, lib, pkgs, vars, ... }:

let
  cfg = config.modules.system.hardware.powersave;

  # Import scripts as derivations
  power-benchmark = pkgs.writeShellScript "power-benchmark" (builtins.readFile ./power-benchmark.sh);
  power-tuning = pkgs.writeShellScript "power-tuning" (builtins.readFile ./power-tuning.sh);

  # Create a package that includes both scripts
  power-tools = pkgs.writeShellScriptBin "power-tools" ''
    case "$1" in
      benchmark)
        shift
        exec ${power-benchmark} "$@"
        ;;
      tune)
        shift
        exec ${power-tuning} "$@"
        ;;
      *)
        echo "Power Tools for ASUS Vivobook Pro 16"
        echo "Usage: power-tools <command> [options]"
        echo ""
        echo "Commands:"
        echo "  benchmark [duration]    Run power consumption benchmarks"
        echo "  tune <command>          Tune power settings"
        echo ""
        echo "Examples:"
        echo "  power-tools benchmark 60"
        echo "  power-tools tune profile max-powersave"
        echo "  power-tools tune status"
        echo ""
        echo "For detailed help:"
        echo "  power-tools benchmark --help"
        echo "  power-tools tune help"
        ;;
    esac
  '';
in {
  options.modules.system.hardware.powersave = {
    enable = lib.mkEnableOption "Enable comprehensive power saving configuration for laptops";

    architecture = lib.mkOption {
      type = lib.types.enum [ "intel" "amd" ];
      default = "amd";
      description = ''
        Select the CPU architecture for power saving optimizations.

        This determines which specific power management features and kernel parameters
        are applied for your processor type.
      '';
      example = "intel";
    };

    enableBenchmarkTools = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = ''
        Install power benchmarking and tuning tools including:
        - power-tools: Comprehensive power management utility
        - power-benchmark: Power consumption measurement script
        - power-tuning: System power tuning script
      '';
    };

    batteryHealth = {
      enable = lib.mkEnableOption "Enable battery health preservation features including charge thresholds";

      chargeThresholds = {
        start = lib.mkOption {
          type = lib.types.int;
          default = lib.max 0 (cfg.batteryHealth.chargeThresholds.stop - 5);
          description = ''
            Start charging when battery level falls below this percentage.

            Recommended to keep 5-10% below the stop threshold for optimal
            battery health preservation.
          '';
          example = 75;
        };

        stop = lib.mkOption {
          type = lib.types.int;
          default = 80;
          description = ''
            Stop charging when battery reaches this percentage.

            Keeping maximum charge level at 80-85% significantly extends
            battery lifespan.
          '';
          example = 80;
        };
      };
    };

    forcePerfOnAC = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = ''
        Force performance mode when connected to AC power.

        This overrides power profile daemon settings to ensure maximum
        performance when plugged in, while maintaining power savings
        on battery.
      '';
    };

    disk = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
      description = ''
        List of disk devices for power management.

        Example: ["sda" "nvme0n1"]
        These disks will have advanced power management features applied
        including APM levels and spindown timeouts.
      '';
      example = [ "nvme0n1" ];
    };

    nvidiaPowerManagement = {
      enable = lib.mkEnableOption "Enable NVIDIA GPU power management features";

      dynamicBoost = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = ''
          Enable NVIDIA Dynamic Boost technology.

          Dynamically balances power between CPU, GPU, and GPU memory
          for optimal performance in gaming and creative workloads.
        '';
      };
    };

    managePowerProfiles = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = ''
        Enable basic power profile management through kernel parameters.

        Note: For advanced control (fan curves, lighting, etc.) use asusctl instead.
        This provides system-level power management while asusctl offers
        hardware-specific features.
      '';
    };

    asus = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = ''
          Enable ASUS-specific hardware support for power management.

          This enables asusctl and supergfxctl services for comprehensive
          control over ASUS laptop features including:
          - GPU mode switching (Integrated, Hybrid, Dedicated)
          - Fan curve control
          - Keyboard lighting
          - Performance profiles
        '';
      };

      armouryCrate = lib.mkOption {
        type = lib.types.bool;
        default = cfg.asus.enable;
        description = ''
          Enable Armoury Crate functionality for ASUS hardware management.

          Provides GUI-like control over system performance profiles and
          hardware features through the asusctl service.
        '';
      };
    };

    override = {
      thermald = lib.mkEnableOption "Override default thermald parameters with custom thermal management settings";
    };
  };

  config = lib.mkIf cfg.enable {
    # Add required packages
    environment.systemPackages = with pkgs; [
      powertop
      acpi
    ] ++ lib.optional (cfg.architecture == "amd") amdctl
      ++ lib.optionals cfg.asus.enable [ asusctl supergfxctl ]
      ++ lib.optionals cfg.enableBenchmarkTools [
        power-tools
        bc # Required for calculations in scripts
        iw # Required for WiFi power management
      ];

    # Enable power management
    powerManagement = {
      enable = true;
      powertop.enable = true;
    };

    # Enable TLP for advanced power management
    services.tlp = {
      enable = true;
      settings = let
        disks = lib.concatStringsSep " " cfg.disk;
        diskSettings = lib.concatStringsSep " " (lib.genList (_: "128") (lib.length cfg.disk));
      in {
        # CPU settings
        CPU_SCALING_GOVERNOR_ON_AC = "performance";
        CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
        CPU_ENERGY_PERF_POLICY_ON_BAT = "power";
        CPU_ENERGY_PERF_POLICY_ON_AC = "performance";
        CPU_BOOST_ON_BAT = 0;
        CPU_BOOST_ON_AC=1;

        # Architecture specific settings
        CPU_HWP_ON_BAT = if cfg.architecture == "amd" then "power" else "balance_performance";

        MEM_SLEEP_ON_AC="s2idle";
        MEM_SLEEP_ON_BAT="deep";

        PLATFORM_PROFILE_ON_BAT = "low-power";
        PLATFORM_PROFILE_ON_AC = if cfg.forcePerfOnAC then "performance" else "balanced";

        # PCIe power management
        PCIE_ASPM_ON_BAT = "powersupersave";
        PCIE_ASPM_ON_AC = "performance";

        # WiFi power saving
        WIFI_PWR_ON_BAT = "on";

        # Audio power saving
        SOUND_POWER_SAVE_ON_BAT = 1;

        # USB autosuspend
        USB_AUTOSUSPEND = 1;
        USB_BLACKLIST_BTUSB = 1;

        # Disk power management
        DISK_DEVICES = disks;
        DISK_APM_LEVEL_ON_BAT = diskSettings;
        DISK_SPINDOWN_TIMEOUT_ON_BAT = diskSettings;

        # Runtime power management
        RUNTIME_PM_ON_BAT = "auto";
        RUNTIME_PM_ALL = 1;

        # NVIDIA GPU power management
        RUNTIME_PM_DRIVER_BLACKLIST = lib.mkIf cfg.nvidiaPowerManagement.enable "nvidia";

        # Explicitly set charge thresholds for all batteries
        # Set charge thresholds for primary battery (BAT0)
        START_CHARGE_THRESH_BAT0 = lib.optionalString cfg.batteryHealth.enable
          cfg.batteryHealth.chargeThresholds.start;
        STOP_CHARGE_THRESH_BAT0 = lib.optionalString cfg.batteryHealth.enable
          cfg.batteryHealth.chargeThresholds.stop;

        # Set charge thresholds for secondary battery (BAT1) if present
        START_CHARGE_THRESH_BAT1 = lib.optionalString cfg.batteryHealth.enable
          cfg.batteryHealth.chargeThresholds.start;
        STOP_CHARGE_THRESH_BAT1 = lib.optionalString cfg.batteryHealth.enable
          cfg.batteryHealth.chargeThresholds.stop;

        # Threshold persistence settings
        # Ensures thresholds are maintained across power state changes
        RESTORE_THRESHOLDS_ON_BAT = lib.optionalString cfg.batteryHealth.enable 1;  # Restore when on battery
        RESTORE_THRESHOLDS_ON_AC = lib.optionalString cfg.batteryHealth.enable 1;  # Restore when on AC power
      };
    };

    # Enable auto-cpufreq for dynamic CPU frequency scaling
    services.auto-cpufreq = {
      enable = true;
      settings = {
        battery = {
          governor = "powersave";
          turbo = "never";
        };
        charger = {
          governor = if cfg.architecture == "amd" then "schedutil" else "performance";
          turbo = "auto";
        };
      };
    };

    # Kernel parameters
    boot.kernelParams =
      (if cfg.managePowerProfiles then [
        "mem_sleep_default=deep"
        "power_supply.wakeup=disabled"
        "libata.force=noncq"
        "pcie_aspm=force"
      ] else []) ++
      (if cfg.architecture == "amd" then [
        "amd_pstate=active"
        "amd_pstate.shared_mem=1"
      ] else [
        "intel_idle.max_cstate=4"
        "processor.max_cstate=5"
      ]) ++
      (if cfg.asus.armouryCrate then [
        "i915.enable_dpcd_backlight=1"
        "nvidia.NVreg_EnableBacklightHandler=0"
      ] else []);

    # Services configuration
    services = {
      thermald.enable = lib.mkDefault (cfg.architecture == "intel" || cfg.override.thermald);
      power-profiles-daemon.enable = lib.mkForce (!(cfg.batteryHealth.enable || cfg.managePowerProfiles));
      upower.enable = true;

      # ASUS control services
      asusd = lib.mkIf cfg.asus.enable {
        enable = true;
        enableUserService = true;
      };
      supergfxd = lib.mkIf cfg.asus.enable {
        enable = true;
        # settings = {
        #   mode = "Hybrid";
        #   vfio_enable = false;
        #   always_reboot = false;
        #   no_logind = false;
        #   logout_timeout_s = 20;
        # };
      };
    };

    hardware.nvidia = lib.mkIf cfg.nvidiaPowerManagement.enable {
      dynamicBoost.enable = cfg.nvidiaPowerManagement.dynamicBoost;
    };

    # Create symlinks to individual scripts for direct access
    environment.etc = lib.mkIf cfg.enableBenchmarkTools {
      "power-scripts/power-benchmark.sh" = {
        source = power-benchmark;
        mode = "0755";
      };
      "power-scripts/power-tuning.sh" = {
        source = power-tuning;
        mode = "0755";
      };
    };
  };
}