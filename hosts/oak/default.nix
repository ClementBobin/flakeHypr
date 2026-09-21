{
  inputs,
  vars,
  lib,
  system,
  pkgs-stable,
  pkgs-unstable,
  ...
}:
let
  pkgs = import inputs.nixpkgs {
    inherit system;
    config = {
      allowUnfree = true;
      permittedInsecurePackages = [
        "electron-41.10.6"
      ];
    };
    overlays = [
      inputs.hydenix.overlays.default
    ];
  };
in
{
  nixpkgs.pkgs = pkgs;

  imports = [
    inputs.home-manager.nixosModules.home-manager
    inputs.hydenix.nixosModules.default
    ./hardware-configuration.nix
    ../../modules/system/hosts/oak


    # === GPU-specific configurations ===

    /*
      For drivers, we are leveraging nixos-hardware
      Most common drivers are below, but you can see more options here: https://github.com/NixOS/nixos-hardware
    */

    #! EDIT THIS SECTION
    # === Other common modules ===
    inputs.nixos-hardware.nixosModules.asus-fa507nv
    inputs.nixos-hardware.nixosModules.common-pc-ssd
    inputs.nixos-hardware.nixosModules.common-hidpi # High-DPI displays
    inputs.nixos-hardware.nixosModules.common-pc-laptop # Laptops
  ];

  home-manager = {
    backupFileExtension = "bak";
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = {
      inherit inputs pkgs-stable pkgs-unstable;
      pkgs-hydenix = pkgs;
    };
    users."${vars.user}" =
      { ... }:
      {
        # hm import
        imports = [
          ../../modules/hm/desktops/hydenix.nix
          ../../modules/hm/hosts/oak
        ];

        desktops.hydenix = {
          enable = true;
          hostname = "oak";
          random = "all";
        };

        home.packages = with pkgs; [
          solidtime-desktop
          flatpak
        ];
      };
  };

  users.users.${vars.user} = {
    isNormalUser = true;
    #initialPassword = "${vars.user}";
    extraGroups = [
      "wheel"
      "networkmanager"
      "video"
      "lp"
      "scanner"
      "adbusers"
    ];
    shell = pkgs.zsh;
  };

  hydenix = {
    enable = true;
    hostname = "oak";
    timezone = "Europe/Paris";
    locale = "fr_FR.UTF-8";
  };

  hardware = {
    asus.battery.chargeUpto = 60;
    nvidia.prime.amdgpuBusId = lib.mkForce "PCI:36:0:0";
  };

  networking = {
    firewall = {
      enable = true;
      allowedTCPPorts = [ 8080 4433 ];
    };
    networkmanager.plugins = with pkgs; [
      networkmanager-fortisslvpn
    ];
  };

  boot.kernelParams = [
    "amdgpu.freesync_video=0"
  ];

  system.stateVersion = "26.05";
}
