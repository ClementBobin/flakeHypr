{
  inputs,
  vars,
  ...
}:
let
  pkgs = import inputs.hydenix.inputs.hydenix-nixpkgs {
    inherit (inputs.hydenix.lib) system;
    config.allowUnfree = true;
    overlays = [
      inputs.hydenix.lib.overlays
      (final: prev: {
        userPkgs = import inputs.nixpkgs {
          inherit (inputs.hydenix.lib) system;
          config.allowUnfree = true;
        };
      })
    ];
  };
in
{

  nixpkgs.pkgs = pkgs;

  imports = [
    inputs.hydenix.inputs.home-manager.nixosModules.home-manager
    inputs.hydenix.lib.nixOsModules
    ./hardware-configuration.nix
    ../../modules/system/hosts/oak


    # === GPU-specific configurations ===

    /*
      For drivers, we are leveraging nixos-hardware
      Most common drivers are below, but you can see more options here: https://github.com/NixOS/nixos-hardware
    */

    #! EDIT THIS SECTION
    # === Other common modules ===
    inputs.hydenix.inputs.nixos-hardware.nixosModules.common-pc
    inputs.hydenix.inputs.nixos-hardware.nixosModules.common-pc-ssd
    inputs.hydenix.inputs.nixos-hardware.nixosModules.asus-fa507nv
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
        imports = [
          ../../modules/hm/hosts/oak
          ../../modules/hm/desktops
        ];

        desktops.hydenix = {
          enable = true;
          hostname = "oak";
        };
      };
  };

  hydenix = {
    enable = true;
    hostname = "oak";
    timezone = "Europe/Paris";
    locale = "fr_FR.UTF-8";
  };

  users.users.${vars.user} = {
    isNormalUser = true;
    initialPassword = "epsilon21C";
    extraGroups = [
      "wheel"
      "networkmanager"
      "video"
    ];
    shell = pkgs.zsh;
  };

  boot.kernelParams = ["video=HDMI-A-1:1920x1080@60"];
}
