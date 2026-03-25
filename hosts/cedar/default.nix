{
  inputs,
  modulesPath,
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
    overlays = [
      inputs.hydenix.overlays.default
    ];
  };
in
{
  nix.settings = { sandbox = false; };
  proxmoxLXC = {
    manageNetwork = false;
    privileged = true;
  };
  security.pam.services.sshd.allowNullPassword = true;
  services.fstrim.enable = false; # Let Proxmox host handle fstrim

  # Cache DNS lookups to improve performance
  services.resolved = {
    extraConfig = ''
      Cache=true
      CacheFromLocalhost=true
    '';
  };

  # =================================== LXC-specific settings ===================================
  nixpkgs.pkgs = pkgs;

  imports = [
    inputs.home-manager.nixosModules.home-manager
    inputs.hydenix.nixosModules.default
    ../../modules/system/hosts/cedar
    (modulesPath + "/virtualisation/proxmox-lxc.nix")


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

  users.users.${vars.user} = {
    isNormalUser = true;
    #initialPassword = "${vars.user}";
    extraGroups = [
      "wheel"
      "networkmanager"
    ];
    shell = pkgs.zsh;
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


  programs.zsh.enable = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.05"; # Did you read the comment?
}
