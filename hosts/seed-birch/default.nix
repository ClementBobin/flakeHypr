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
    };
  };
in
{
  nixpkgs.pkgs = pkgs;

  imports = [
    ./hardware-configuration.nix
    ../../modules/system/hosts/seed-birch


    # === GPU-specific configurations ===

    /*
      For drivers, we are leveraging nixos-hardware
      Most common drivers are below, but you can see more options here: https://github.com/NixOS/nixos-hardware
    */

    #! EDIT THIS SECTION
    # === Other common modules ===
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
          ../../modules/hm/hosts/seed-birch
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
    ];
    shell = pkgs.zsh;
  };

  system.stateVersion = "25.05";
}
