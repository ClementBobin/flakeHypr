{
  inputs,
  vars,
  ...
}:
let
  pkgs = import inputs.hydenix.inputs.hydenix-nixpkgs {
    inherit (inputs.hydenix.lib) system;
    config = {
      android_sdk.accept_license = true;
      allowUnfree = true;
    };
    overlays = [
      inputs.hydenix.lib.overlays
      (final: prev: {
        userPkgs = import inputs.nixpkgs {
          inherit (inputs.hydenix.lib) system;
          config.allowUnfree = true;
          android_sdk.accept_license = true;
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

  boot.kernelParams = [ "video=HDMI-A-1:e" ];

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
          ../../modules/hm/desktops
          ../../modules/hm/hosts/oak
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

  services = {
    printing = {                            # CUPS
      enable = true;
      drivers = [ pkgs.cnijfilter2 ];
    };
  };
}
