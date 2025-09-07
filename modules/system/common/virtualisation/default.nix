{ config, lib, pkgs, vars, ... }:

let
  inherit (lib) mkEnableOption mkOption types;

  cfg = config.modules.system.virtualisation;

  # List of supported virtualization engines
  supportedEngines = [ "libvirtd" "podman" "docker" "waydroid" "lxd" ];

  # List of supported GUI clients
  supportedClients = [ "virt-manager" "droidcam" "quickemu" ];

  # Map emulators to their packages
  emulatorToPackage = with pkgs; {
    playonlinux = [ playonlinux ];
    bottles = [ bottles ];
    dosbox = [ dosbox ];
    qemu = [ qemu ];
    virtualbox = [ virtualbox ];
  };

  # Wine packages based on version
  winePackages = with pkgs; {
    stable = wine-stable;
    staging = wine-staging;
    wayland = wineWayland;
    fonts = winePackages.stable;
  };

  # Proton packages
  protonPackages = with pkgs; [
    protonup-qt
    protontricks
    proton-caller
  ];

  # Get packages for enabled emulators
  baseEmulatorPackages = lib.concatMap (emulator: emulatorToPackage.${emulator} or []) cfg.emulators;

  # Additional packages based on configuration
  additionalPackages = with pkgs; []
    ++ lib.optionals cfg.wine.enable [ (winePackages.${cfg.wine.version} or pkgs.wine-stable) winetricks ]
    ++ lib.optionals cfg.proton.enable protonPackages
    ++ lib.optionals (lib.elem "podman" cfg.engines) [ podman-compose ]
    ++ lib.optionals (lib.elem "docker" cfg.engines) [ docker-compose ];
in {
  options.modules.system.virtualisation = {
    enable = mkEnableOption "system virtualization support";

    engines = mkOption {
      type = types.listOf (types.enum supportedEngines);
      default = [];
      description = "List of virtualization engines to enable";
    };

    gui.clients = mkOption {
      type = types.listOf (types.enum supportedClients);
      default = [];
      description = "List of virtualization GUI clients to install";
    };

    emulators = mkOption {
      type = types.listOf (types.enum (builtins.attrNames emulatorToPackage));
      default = [];
      description = "List of emulators to install";
    };

    wine = {
      enable = mkEnableOption "Wine compatibility layer";
      version = mkOption {
        type = types.enum (builtins.attrNames winePackages);
        default = "stable";
        description = "Wine version to use";
      };
    };

    proton = {
      enable = mkEnableOption "Proton compatibility layer";
    };

    spiceUSBRedirection = {
      enable = mkEnableOption "SPICE USB redirection";
    };
  };

  config = lib.mkMerge [
    (lib.mkIf cfg.enable {
      # Common virtualization configuration
      virtualisation = {
        spiceUSBRedirection.enable = cfg.spiceUSBRedirection.enable;
      };

      users.users.${vars.user}.extraGroups = ["kvm" "input"]
        ++ lib.optionals (lib.elem "libvirtd" cfg.engines) ["libvirtd"]
        ++ lib.optionals (lib.elem "docker" cfg.engines) ["docker"]
        ++ lib.optionals (lib.elem "podman" cfg.engines) ["podman"]
        ++ lib.optionals (lib.elem "lxd" cfg.engines) ["lxd"];
    })

    (lib.mkIf (lib.elem "libvirtd" cfg.engines) {
      virtualisation.libvirtd = {
        enable = true;
        qemu = {
          runAsRoot = true;
          swtpm.enable = true;
          ovmf.enable = true;
        };
      };
    })

    (lib.mkIf (lib.elem "podman" cfg.engines) {
      virtualisation.podman = {
        enable = true;
        dockerCompat = true;
        defaultNetwork.settings.dns_enabled = true;
      };
    })

    (lib.mkIf (lib.elem "docker" cfg.engines) {
      virtualisation.docker = {
        enable = true;
        autoPrune.enable = true;
        enableOnBoot = lib.mkDefault false;
      };
    })

    (lib.mkIf (lib.elem "lxd" cfg.engines) {
      virtualisation.lxd.enable = true;
    })

    (lib.mkIf (lib.elem "waydroid" cfg.engines) {
      virtualisation.waydroid.enable = true;
      environment.systemPackages = [ pkgs.waydroid ];
    })

    (lib.mkIf (lib.elem "virt-manager" cfg.gui.clients) {
      programs.virt-manager.enable = true;
    })

    (lib.mkIf (lib.elem "droidcam" cfg.gui.clients) {
      environment.systemPackages = [ pkgs.droidcam ];
    })

    (lib.mkIf (cfg.emulators != []) {
      environment.systemPackages = baseEmulatorPackages;
    })

    (lib.mkIf (cfg.wine.enable || cfg.proton.enable) {
      environment.systemPackages = additionalPackages;
    })
  ];
}