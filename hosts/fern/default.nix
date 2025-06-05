{
  inputs,
  vars,
  ...
}:
let
  pkgs = import inputs.hydenix.inputs.hydenix-nixpkgs {
    inherit (inputs.hydenix.lib) system;
    config.allowUnfree = true;
    config.allowBroken = true;
    overlays = [
      inputs.hydenix.lib.overlays
      (final: prev: {
        userPkgs = import inputs.nixpkgs {
          inherit (inputs.hydenix.lib) system;
          config.allowUnfree = true;
          config.allowBroken = true;
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
    ../../modules/system/hosts/fern
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
          ../../modules/hm/desktops
        ];

        desktops.hydenix = {
          enable = true;
          hostname = "fern";
        };
      };
  };

  hydenix = {
    enable = true;
    hostname = "fern";
    timezone = "America/Vancouver";
    locale = "en_CA.UTF-8";
  };

  users.users.${vars.user} = {
    isNormalUser = true;
    initialPassword = "${vars.user}";
    extraGroups = [
      "wheel"
      "networkmanager"
      "video"
    ];
    shell = pkgs.zsh;
  };
}
