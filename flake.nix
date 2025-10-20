{
  description = "template for hydenix";

  inputs = {
    # User's nixpkgs - for user packages
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/release-25.05";
    nix-gaming.url = "github:fufexan/nix-gaming";

    # Hydenix and its nixpkgs - kept separate to avoid conflicts
    hydenix.url = "github:richen604/hydenix";
    nixos-hardware.url = "github:nixos/nixos-hardware/master";

    caelestia-shell.url = "github:caelestia-dots/shell";
    caelestia-cli.url = "github:caelestia-dots/cli";

    nix-podman-stacks = {
      url = "github:Tarow/nix-podman-stacks";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, ... }@inputs:
    let
      vars = {
        user = "mirage";
      };
      system = "x86_64-linux";

      # Create a function to generate host configurations
      mkHost = hostname: inputs.nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = {
            inherit inputs vars system;
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
        fern = mkHost "fern";
        oak = mkHost "oak";
        pine = mkHost "pine";
        cedar = mkHost "cedar";
        default = mkHost "oak";
      };

      packages.${system} = {
        cedar-vm = mkVm "cedar";
        fern-vm = mkVm "fern";
        oak-vm = mkVm "oak";

        fern = self.nixosConfigurations.fern.config.system.build.toplevel;
        oak = self.nixosConfigurations.oak.config.system.build.toplevel;
        cedar = self.nixosConfigurations.cedar.config.system.build.toplevel;
      };
    };
}