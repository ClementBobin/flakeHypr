{
  inputs,
  vars,
  lib,
  system,
  ...
}:
let
  pkgs = import inputs.nixpkgs {
    inherit system;
    config = {
      allowUnfree = true;
      permittedInsecurePackages = [
        "jitsi-meet-1.0.8792"
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
    #./temp.nix
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
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = {
      inherit inputs;
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
        };
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
    ];
    shell = pkgs.zsh;
  };

  hydenix = {
    enable = true;
    hostname = "oak";
    timezone = "Europe/Paris";
    locale = "fr_FR.UTF-8";
    gaming.enable = false;
  };

  hardware = {
    asus.battery.chargeUpto = 60;
    nvidia.prime.amdgpuBusId = lib.mkForce "PCI:36:0:0";
  };

  #boot.kernel.sysctl."net.ipv4.ip_unprivileged_port_start" = 0;

  system.stateVersion = "25.05";
}
