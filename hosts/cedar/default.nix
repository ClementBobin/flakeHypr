{
  inputs,
  vars,
  lib,
  ...
}:
let
  pkgs = import inputs.hydenix.inputs.hydenix-nixpkgs {
    inherit (inputs.hydenix.lib) system;
    config = {
      allowUnfree = true;
    };
    overlays = [
      inputs.hydenix.lib.overlays
      (final: prev: {
        userPkgs = import inputs.nixpkgs {
          inherit (inputs.hydenix.lib) system;
          config = {
            allowUnfree = true;
          };
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
    ../../modules/system/hosts/cedar


    # === GPU-specific configurations ===

    /*
      For drivers, we are leveraging nixos-hardware
      Most common drivers are below, but you can see more options here: https://github.com/NixOS/nixos-hardware
    */

    #! EDIT THIS SECTION
    # === Other common modules ===
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
          ../../modules/hm/hosts/cedar
        ];

        desktops.hydenix = {
          enable = false;
          hostname = "cedar";
        };
      };
  };

  hydenix = {
    enable = true;
    hostname = "cedar";
    timezone = "Europe/Paris";
    locale = "fr_FR.UTF-8";

    audio.enable = false;
    sddm.enable = false;
    boot.useSystemdBoot = false;
    hardware.enable = false;
    system.enable = false;
    gaming.enable = false;
  };

  boot.loader = {
    grub = {
      device = lib.mkForce "/dev/sda";
      efiSupport = lib.mkForce false;
    };
    efi.canTouchEfiVariables = lib.mkForce false;
  };

  # Select internationalisation properties.
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "fr_FR.UTF-8";
    LC_IDENTIFICATION = "fr_FR.UTF-8";
    LC_MEASUREMENT = "fr_FR.UTF-8";
    LC_MONETARY = "fr_FR.UTF-8";
    LC_NAME = "fr_FR.UTF-8";
    LC_NUMERIC = "fr_FR.UTF-8";
    LC_PAPER = "fr_FR.UTF-8";
    LC_TELEPHONE = "fr_FR.UTF-8";
    LC_TIME = "fr_FR.UTF-8";
  };
  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "fr";
    variant = "";
  };
  # Configure console keymap
  console.keyMap = "fr";
  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.${vars.user} = {
    isNormalUser = true;
    description = "${vars.user}";
    # initialPassword = "${vars.user}"; # Uncomment to set a password on first boot.
    extraGroups = [ "networkmanager" "wheel" "nix-ssh" ];
    shell = pkgs.zsh;
  };

  programs.zsh.enable = true;
  # Enable automatic login for the user.
  services.getty.autologinUser = "${vars.user}";

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.05"; # Did you read the comment?
}
