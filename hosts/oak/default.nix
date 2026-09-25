{
  inputs,
  vars,
  lib,
  system,
  pkgs,
  pkgs-unstable,
  ...
}:
{
  imports = [
    inputs.hydenix.inputs.home-manager.nixosModules.home-manager
    inputs.hydenix.nixosModules.default
    ./hardware-configuration.nix
    ../../modules/system/hosts/oak

    # === GPU-specific configurations ===
    inputs.nixos-hardware.nixosModules.asus-fa507nv
    inputs.nixos-hardware.nixosModules.common-pc-ssd
    inputs.nixos-hardware.nixosModules.common-hidpi
    inputs.nixos-hardware.nixosModules.common-pc-laptop
  ];

  home-manager = {
    backupFileExtension = "bak";
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = {
      inherit inputs pkgs pkgs-unstable;
    };
    users."${vars.user}" = { ... }: {

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
        flatpak
      ];
    };
  };

  users.users.${vars.user} = {
    isNormalUser = true;
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
    boot.kernelPackages = pkgs.linuxPackages_6_12;
  };

  hardware = {
    asus.battery.chargeUpto = 60;
    nvidia = {
      prime.amdgpuBusId = lib.mkForce "PCI:36:0:0";
    };
  };

  networking = {
    firewall = {
      enable = true;
      allowedTCPPorts = [ 8080 4433 ];
    };
  };

  boot.kernelParams = [
    "amdgpu.freesync_video=0"
  ];

  system.stateVersion = "26.05";
}