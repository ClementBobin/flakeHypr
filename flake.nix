{
  description = "template for hydenix";

  inputs = {
    # User's nixpkgs - for user packages
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/release-25.05";
    nix-gaming.url = "github:fufexan/nix-gaming";
    sops-nix.url = "github:Mic92/sops-nix";

    # Hydenix and its nixpkgs - kept separate to avoid conflicts
    hydenix.url = "github:richen604/hydenix/v5.0.0";
    nixos-hardware.url = "github:nixos/nixos-hardware/master";

    nix-podman-stacks = {
      url = "github:Tarow/nix-podman-stacks";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    spicetify-nix.url = "github:Gerg-L/spicetify-nix";

    zen-browser = {
      url = "github:youwen5/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    linux-wallpaper-engine.url = "github:jagrat7/linux-wallpaper-engine";
  };

  outputs = { self, ... }@inputs:
    let
      vars = {
        user = "mirage";
      };
      system = "x86_64-linux";

      # Create a function to generate host configurations
      mkHost = hostname: extraVars: inputs.nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = {
          inherit inputs system;
          vars = vars // extraVars;
          hostname = hostname;
        };
        modules = [
          ./hosts/${hostname}
        ];
      };

      # Create VM variant function
      mkVm = hostname:
        (import ./hosts/vm.nix {
          inherit inputs hostname vars;
          nixosConfiguration = mkHost hostname;
        }).config.system.build.vm;

      isoConfig = inputs.hydenix.lib.iso {
        hydenix-inputs = inputs.hydenix.inputs // inputs.hydenix.lib // inputs.hydenix;
        flake = inputs.self.outPath;
      };

      pkgs = import inputs.nixpkgs { inherit system; };
    in
    {
      nixosConfigurations = {
        fern = mkHost "fern" {};
        oak = mkHost "oak" {};
        pine = mkHost "pine" {};
        cedar = mkHost "cedar" {};

        # Override vars for birch-seed specifically
        birch-seed = mkHost "birch-seed" { user = "fanny"; };

        default = mkHost "oak" {};
      };

      packages.${system} = {
        cedar-vm = mkVm "cedar";
        fern-vm = mkVm "fern";
        pine-vm = mkVm "pine";
        birch-seed-vm = mkVm "birch-seed";
        oak-vm = mkVm "oak";

        fern = self.nixosConfigurations.fern.config.system.build.toplevel;
        birch-seed = self.nixosConfigurations.birch-seed.config.system.build.toplevel;
        pine = self.nixosConfigurations.pine.config.system.build.toplevel;
        oak = self.nixosConfigurations.oak.config.system.build.toplevel;
        cedar = self.nixosConfigurations.cedar.config.system.build.toplevel;
      };

      nixosModules = {
        common = import ./modules/system/common;
        hm = import ./modules/hm/common;
        wrapper = import ./modules/wrapper;
      };
    };
}
