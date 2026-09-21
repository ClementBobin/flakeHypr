{
  description = "template for hydenix";

  inputs = {
    # User's nixpkgs - for user packages
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/release-25.05";
    nix-gaming.url = "github:fufexan/nix-gaming";

    # Hydenix and its nixpkgs - kept separate to avoid conflicts
    #hydenix.url = "path:/home/mirage/Documents/dev/multi-stack-project/nixos/hydenix";
    hydenix.url = "github:ClementBobin/hydenix/v1.18.0";
    nixos-hardware.url = "github:nixos/nixos-hardware/master";

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
          pkgs-unstable = import inputs.nixpkgs {
            inherit system;
            config.allowUnfree = true;
            config.permittedInsecurePackages = [
              "electron-39.8.10"
            ];
          };
          pkgs-stable = import inputs.nixpkgs-stable {
            inherit system;
            config.allowUnfree = true;
          };
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
