{ config, lib, pkgs, vars, ... }:

let
  cfg = config.modules.system.hardware.powersave;
in {
  options.modules.system.hardware.powersave = {
    enable = lib.mkEnableOption "Enable power saving configuration";

    architecture = lib.mkOption {
      type = lib.types.enum [ "intel" "amd" ];
      default = "amd";
      description = "Select the architecture for power saving optimizations";
    };

    batteryHealth = {
      enable = lib.mkEnableOption "Enable battery health preservation features";
      chargeThresholds = {
        start = lib.mkOption {
          type = lib.types.int;
          default = 75;
          description = "Start charging when battery falls below this percentage";
        };
        stop = lib.mkOption {
          type = lib.types.int;
          default = 80;
          description = "Stop charging when battery reaches this percentage";
        };
      };
    };

    disk = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
      description = "List of disks for power management";
    };

    managePowerProfiles = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = ''
        Enable basic power profile management through kernel parameters.
        Note: For advanced control (fan curves, lighting, etc.) use asusctl instead.
      '';
    };

    asus = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable ASUS hardware support for power management.";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    # Add required packages
    environment.systemPackages = with pkgs; [
      powertop
      acpi
    ] ++ lib.optional (cfg.architecture == "amd") amdctl
      ++ lib.optionals cfg.asus.enable [ asusctl supergfxctl ];

    # Enable power management
    powerManagement = {
      enable = true;
      cpuFreqGovernor = lib.mkDefault "powersave";
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
        CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
        CPU_ENERGY_PERF_POLICY_ON_BAT = "power";
        CPU_BOOST_ON_BAT = 0;

        # Architecture specific settings
        CPU_HWP_ON_BAT = if cfg.architecture == "amd" then "power" else "balance_performance";
        PLATFORM_PROFILE_ON_BAT = "low-power";

        # PCIe power management
        PCIE_ASPM_ON_BAT = "powersupersave";

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

        # Explicitly set charge thresholds for all batteries
        START_CHARGE_THRESH_BAT0 = cfg.batteryHealth.chargeThresholds.start;
        STOP_CHARGE_THRESH_BAT0 = cfg.batteryHealth.chargeThresholds.stop;
        START_CHARGE_THRESH_BAT1 = cfg.batteryHealth.chargeThresholds.start;
        STOP_CHARGE_THRESH_BAT1 = cfg.batteryHealth.chargeThresholds.stop;

        # Ensure TLP applies these thresholds
        RESTORE_THRESHOLDS_ON_BAT = 1;
        RESTORE_THRESHOLDS_ON_AC = 1;
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
          governor = if cfg.architecture == "amd" then "ondemand" else "performance";
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
      ]);

    # Services configuration
    services = {
      thermald.enable = lib.mkDefault (cfg.architecture == "intel");
      power-profiles-daemon.enable = lib.mkForce (!(cfg.batteryHealth.enable || cfg.managePowerProfiles));
      upower.enable = true;

      # ASUS control services
      asusd = lib.mkIf cfg.asus.enable {
        enable = true;
        enableUserService = true;
      };
      supergfxd = lib.mkIf cfg.asus.enable {
        enable = true;
      };
    };
  };
}