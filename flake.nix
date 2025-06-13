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

    deploy-rs = {
      url = "github:serokell/deploy-rs";
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

      # All below is for deploy-rs
      system = inputs.hydenix.lib.system;
      pkgs = import inputs.nixpkgs {
        inherit system;
        overlays = [ inputs.deploy-rs.overlays.default ];
      };

      mkDeployNode = hostname: {
        hostname = hostname;
        profiles.system = {
          # Change from root to your user
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
        "fern.local" = mkHost "fern";
        "oak.local" = mkHost "oak";
      };

      deploy.nodes = {
        fern = mkDeployNode "fern.local";
        oak = mkDeployNode "oak.local";
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
        "all")
          ${pkgs.deploy-rs}/bin/deploy --skip-checks .#oak
          ${pkgs.deploy-rs}/bin/deploy --skip-checks .#fern
          ;;
        *) echo "Usage: rb [oak|fern|all]" >&2; exit 1 ;;
          esac
        '';
      };

      # Only check the specific deployment node
      checks.${system} = {
        oak-check = inputs.deploy-rs.lib.${system}.deployChecks {
          nodes.oak = inputs.self.deploy.nodes.oak;
        };
        fern-check = inputs.deploy-rs.lib.${system}.deployChecks {
          nodes.fern = inputs.self.deploy.nodes.fern;
        };
      };
    };
}
