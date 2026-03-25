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

  # Bootloader.
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sda";
  boot.loader.grub.useOSProber = true;

  imports = [
    inputs.home-manager.nixosModules.home-manager
    inputs.hydenix.nixosModules.default
    ./hardware-configuration.nix
    ../../modules/system/hosts/birch-seed


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
          ../../modules/hm/desktops/hydenix.nix
          ../../modules/hm/hosts/birch-seed
        ];

        desktops.hydenix = {
          enable = false;
          hostname = "birch-seed";
        };

        home.packages = with pkgs; [
          kitty
        ];
      };
  };

  hydenix = {
    enable = true;
    hostname = "birch-seed";
    timezone = "Europe/Paris";
    locale = "fr_FR.UTF-8";
    gaming.enable = false;
    boot.enable = false;
    sddm.enable = false;
  };

  # Enable the X11 windowing system.
  # You can disable this if you're only using the Wayland session.
  services.xserver.enable = true;

  # Enable the KDE Plasma Desktop Environment.
  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "fr";
    variant = "";
  };

  # Configure console keymap
  console.keyMap = "fr";

  # Enable CUPS to print documents.
  #services.printing.enable = true;

  # Enable sound with pipewire.
  # services.pulseaudio.enable = false;
  # security.rtkit.enable = true;
  # services.pipewire = {
  #   enable = true;
  #   alsa.enable = true;
  #   alsa.support32Bit = true;
  #   pulse.enable = true;
  #   # If you want to use JACK applications, uncomment this
  #   #jack.enable = true;

  #   # use the example session manager (no others are packaged yet so this is enabled by default,
  #   # no need to redefine it in your config for now)
  #   #media-session.enable = true;
  # };

  users.users."${vars.user}" = {
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

  # Enable automatic login for the user.
  services.displayManager.autoLogin.enable = true;
  services.displayManager.autoLogin.user = "${vars.user}";

  system.stateVersion = "25.05";
}
