{
  description = "template for hydenix";

  inputs = {
    chaotic.url = "github:chaotic-cx/nyx/nyxpkgs-unstable";

    # User's nixpkgs - for user packages
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/release-24.05";
    nix-gaming.url = "github:fufexan/nix-gaming";

    # Hydenix and its nixpkgs - kept separate to avoid conflicts
    hydenix = {
      url = "github:richen604/hydenix";
    };

    # Nix-index-database - for comma and command-not-found
    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    deploy-rs = {
      url = "github:serokell/deploy-rs";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nix-darwin, ... }@inputs:
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

      # Create macOS configuration
      mkDarwinHost =
        hostname:
        nix-darwin.lib.darwinSystem {
          system = "aarch64-darwin"; # or "x86_64-darwin" for Intel Macs
          specialArgs = {
            inherit inputs vars;
            hostname = hostname;
          };
          modules = [
            ./hosts/darwin/${hostname}
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

      # All below is for deploy-rs
      system = inputs.hydenix.lib.system;
      pkgs = import inputs.nixpkgs {
        inherit system;
        overlays = [ inputs.deploy-rs.overlays.default ];
      };

      mkDeployNode = hostname: {
        hostname = hostname;
        profiles.system = {
          user = "${vars.user}";
          path = inputs.deploy-rs.lib.${system}.activate.nixos inputs.self.nixosConfigurations.${hostname};
          sshUser = "${vars.user}";
          interactiveSudo = true;
          sshOpts = [
            "-p"
            "22"
          ];
          magicRollback = true;
          confirmTimeout = 300;
        };
      };
    in
    {
      nixosConfigurations = {
        fern = mkHost "fern";
        oak = mkHost "oak";
        pine = mkHost "pine";
        "fern.local" = mkHost "fern";
        "oak.local" = mkHost "oak";
        "pine.local" = mkHost "pine";
      };

      darwinConfigurations = {
        # Replace "macbook" with your actual hostname (run 'scutil --get LocalHostName' to find it)
        macbook = mkDarwinHost "macbook";
      };

      deploy.nodes = {
        fern = mkDeployNode "fern.local";
        oak = mkDeployNode "oak.local";
        pine = mkDeployNode "pine.local";
      };

      packages.${inputs.hydenix.lib.system} = {
        fern-vm = mkVm "fern";
        oak-vm = mkVm "oak";

        build-iso = isoConfig.build-iso;
        burn-iso = isoConfig.burn-iso;

        rb = pkgs.writeShellScriptBin "rb" ''
          set -euo pipefail
          host=$1
          case "$host" in
        "oak")
          ${pkgs.deploy-rs}/bin/deploy --skip-checks .#oak ;;
        "fern")
          ${pkgs.deploy-rs}/bin/deploy --skip-checks .#fern ;;
        "pine")
          ${pkgs.deploy-rs}/bin/deploy --skip-checks .#pine ;;
        "all")
          ${pkgs.deploy-rs}/bin/deploy --skip-checks .#oak
          ${pkgs.deploy-rs}/bin/deploy --skip-checks .#fern
          ${pkgs.deploy-rs}/bin/deploy --skip-checks .#pine
          ;;
        *) echo "Usage: rb [oak|fern|pine|all]" >&2; exit 1 ;;
          esac
        '';
      };

      checks.${system} = {
        oak-check = inputs.deploy-rs.lib.${system}.deployChecks {
          nodes.oak = inputs.self.deploy.nodes.oak;
        };
        fern-check = inputs.deploy-rs.lib.${system}.deployChecks {
          nodes.fern = inputs.self.deploy.nodes.fern;
        };
        pine-check = inputs.deploy-rs.lib.${system}.deployChecks {
          nodes.pine = inputs.self.deploy.nodes.pine;
        };
      };
    };
}