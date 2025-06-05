{
  description = "template for hydenix";

  inputs = {
    chaotic.url = "github:chaotic-cx/nyx/18c577a2a160453f4a6b4050fb0eac7d28b92ead";

    # User's nixpkgs - for user packages
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/release-24.05";
    nix-gaming.url = "github:fufexan/nix-gaming";

    flake-utils.url = "github:numtide/flake-utils";

    # Hydenix and its nixpkgs - kept separate to avoid conflicts
    hydenix = {
      # Available inputs:
      # Main: github:richen604/hydenix
      # Dev: github:richen604/hydenix/dev
      # Commit: github:richen604/hydenix/<commit-hash>
      # Version: github:richen604/hydenix/v1.0.0
      url = "github:richen604/hydenix";
    };

    # Nix-index-database - for comma and command-not-found
    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      ...
    }@inputs:
    let
      vars = {
        user = "mirage";
      };

      # Create a function to generate host configurations
      mkHost =
        hostname:
        inputs.hydenix.inputs.hydenix-nixpkgs.lib.nixosSystem {
          inherit (inputs.hydenix.lib) system;
          specialArgs = {
            inherit inputs vars;
            hostname = hostname;
          };
          modules = [
            ./hosts/${hostname}
          ];
        };

      # Create VM variant function
      mkVm =
        hostname:
        (import ./hosts/vm.nix {
          inherit inputs hostname vars;
          nixosConfiguration = mkHost hostname;
        }).config.system.build.vm;

      isoConfig = inputs.hydenix.lib.iso {
        hydenix-inputs = inputs.hydenix.inputs // inputs.hydenix.lib // inputs.hydenix;
        flake = inputs.self.outPath;
      };
    in
    {
      nixosConfigurations = {
        fern = mkHost "fern";
        oak = mkHost "oak";
        # TODO: temp host for rebuild iso
        nixos = mkHost "oak";
      };

      packages.${inputs.hydenix.lib.system} = {
        fern-vm = mkVm "fern";
        oak-vm = mkVm "oak";
        build-iso = isoConfig.build-iso;
        burn-iso = isoConfig.burn-iso;
      };
    };
}
