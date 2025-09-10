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
    enable = mkEnableOption ''
      System virtualization and emulation support
      
      This module provides comprehensive virtualization support including:
      - Container engines (Docker, Podman, LXD)
      - Virtual machine managers (libvirt/QEMU, VirtualBox)
      - Compatibility layers (Wine, Proton)
      - Android emulation (Waydroid)
      - Various system emulators
      
      Enabling this module will configure the necessary system services and
      user permissions for running virtual machines and containers.
    '';

    engines = mkOption {
      type = types.listOf (types.enum supportedEngines);
      default = [];
      example = [ "libvirtd" "docker" "podman" ];
      description = ''
        List of virtualization engines to enable and configure.
        
        Supported engines:
        - libvirtd: KVM/QEMU virtual machine management with libvirt
        - podman: Daemonless container engine (rootless containers)
        - docker: Docker container platform with daemon
        - waydroid: Android containerization for running Android apps
        - lxd: System container and virtual machine manager
        
        Each enabled engine will:
        - Start necessary system services
        - Configure required kernel modules
        - Add the user to appropriate groups
        - Set up default configurations
      '';
    };

    gui.clients = mkOption {
      type = types.listOf (types.enum supportedClients);
      default = [];
      example = [ "virt-manager" "quickemu" ];
      description = ''
        Graphical user interfaces for virtualization management.
        
        Available clients:
        - virt-manager: GUI for managing libvirt virtual machines
        - droidcam: Android camera virtualization for use as webcam
        - quickemu: Quick GUI for creating and managing VMs
        
        These packages provide user-friendly interfaces for managing
        virtual machines and containers without using command-line tools.
      '';
    };

    emulators = mkOption {
      type = types.listOf (types.enum (builtins.attrNames emulatorToPackage));
      default = [];
      example = [ "qemu" "dosbox" "bottles" ];
      description = ''
        System emulators and compatibility tools.
        
        Available emulators:
        - playonlinux: GUI for managing Wine prefixes and Windows applications
        - bottles: Sandboxed Windows application environment
        - dosbox: DOS emulator for running classic DOS games and applications
        - qemu: Generic machine emulator and virtualizer
        - virtualbox: Oracle VirtualBox virtualization platform
        
        Note: Some emulators may require additional configuration or
        kernel modules to function properly.
      '';
    };

    wine = {
      enable = mkEnableOption ''
        Wine Windows compatibility layer
      
        Wine (Wine Is Not an Emulator) allows running Windows applications
        on Linux systems. When enabled, this provides:
        - Windows API implementation on Unix
        - Application binary interface translation
        - Windows program loader and utilities
        
        This is useful for running Windows games and applications without
        a full virtual machine. Wine works best with older applications
        and games that don't require advanced DirectX features.
      '';
      
      version = mkOption {
        type = types.enum (builtins.attrNames winePackages);
        default = "stable";
        example = "staging";
        description = ''
          Wine version to install and configure.
          
          Available versions:
          - stable: Most tested and reliable version
          - staging: Includes experimental patches and features
          - wayland: Experimental Wayland support
          - fonts: Wine with additional font support
          
          The staging version often has better compatibility with newer
          games and applications but may be less stable.
        '';
      };
    };

    proton = {
      enable = mkEnableOption ''
        Proton Steam compatibility layer
      
        Proton is Valve's compatibility tool for running Windows games
        on Linux through Steam. It's based on Wine with additional
        gaming-specific enhancements:
        - DirectX 11 and 12 support through DXVK/VKD3D
        - Improved game controller support
        - Better fullscreen and overlay handling
        - Steam integration
        
        Proton provides significantly better gaming performance than
        standard Wine for many modern Windows games.
      '';
    };

    spiceUSBRedirection = {
      enable = mkEnableOption ''
        SPICE USB redirection support
      
        SPICE (Simple Protocol for Independent Computing Environments)
        USB redirection allows USB devices to be passed through to
        virtual machines. This enables:
        - USB storage devices in VMs
        - USB peripherals (keyboards, mice, game controllers)
        - Specialized USB hardware access
        - Smart card readers and security devices
        
        This is particularly useful for virtual desktop infrastructure
        and remote VM access scenarios.
      '';
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