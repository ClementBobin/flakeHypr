{
  description = "template for hydenix";

  inputs = {
    chaotic.url = "github:chaotic-cx/nyx/nyxpkgs-unstable";

    # User's nixpkgs - for user packages
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/release-25.05";
    nix-gaming.url = "github:fufexan/nix-gaming";

    # Hydenix and its nixpkgs - kept separate to avoid conflicts
    hydenix.url = "github:richen604/hydenix/v4.9.0";

    # Nix-index-database - for comma and command-not-found
    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-podman-stacks = {
      url = "github:Tarow/nix-podman-stacks";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, ... }@inputs:
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

      system = inputs.hydenix.lib.system;
      pkgs = import inputs.nixpkgs { inherit system; };

      # Host configuration mapping
      hostConfigs = {
        fern = { hostname = "fern"; ip = "fern"; };
        oak = { hostname = "oak"; ip = "oak"; };
        pine = { hostname = "pine"; ip = "pine"; };
        cedar = { hostname = "cedar"; ip = "cedar"; };
      };

    in
    {
      nixosConfigurations = {
        fern = mkHost "fern";
        oak = mkHost "oak";
        pine = mkHost "pine";
        cedar = mkHost "cedar";
      };

      packages.${system} = {
        cedar-vm = mkVm "cedar";
        fern-vm = mkVm "fern";
        oak-vm = mkVm "oak";

        fern = self.nixosConfigurations.fern.config.system.build.toplevel;
        oak = self.nixosConfigurations.oak.config.system.build.toplevel;
        cedar = self.nixosConfigurations.cedar.config.system.build.toplevel;

        # Replacement for deploy-rs: nixos-rebuild based deployment script
        rb = pkgs.writeShellScriptBin "rb" ''
          set -euo pipefail
          
          host=$1
          shift  # Remove the first argument (hostname)
          
          # Parse additional flags
          build_host=""
          extra_args=()
          
          while [[ $# -gt 0 ]]; do
            case "$1" in
              --build-host=*)
                build_host="''${1#*=}"
                shift
                ;;
              --build-host)
                build_host="$2"
                shift 2
                ;;
              --remote-build)
                build_host="''${hostConfigs[$host]:-$host}"
                shift
                ;;
              --local-build)
                build_host="localhost"
                shift
                ;;
              *)
                extra_args+=("$1")
                shift
                ;;
            esac
          done
          
          # Get host configuration
          case "$host" in
            "oak"|"fern"|"pine"|"cedar")
              target_host="''${hostConfigs[$host]}"
              ;;
            "all")
              # Deploy to all hosts sequentially
              echo "Deploying to all hosts..."
              for h in oak fern pine cedar; do
                echo "=== Deploying to $h ==="
                ${pkgs.nix}/bin/nixos-rebuild switch \
                  --flake ".#$h" \
                  --target-host "$h" \
                  --sudo \
                  "''${extra_args[@]}"
              done
              exit 0
              ;;
            *)
              echo "Usage: rb [oak|fern|pine|cedar|all] [OPTIONS] [-- nixos-rebuild-args]"
              echo ""
              echo "Options:"
              echo "  --build-host=HOST      Build on specified host"
              echo "  --remote-build         Build on target host (default)"
              echo "  --local-build          Build on local machine"
              echo "  -- nixos-rebuild-args  Additional arguments to nixos-rebuild"
              echo ""
              echo "Examples:"
              echo "  rb cedar                          # Build on cedar, deploy to cedar"
              echo "  rb cedar --local-build            # Build locally, deploy to cedar"
              echo "  rb cedar --build-host=fern        # Build on fern, deploy to cedar"
              echo "  rb cedar -- --show-trace          # Pass --show-trace to nixos-rebuild"
              exit 1
              ;;
          esac
          
          # Build the nixos-rebuild command
          cmd=(
            ${pkgs.nix}/bin/nixos-rebuild
            switch
            --flake ".#$host"
            --target-host "$target_host"
            --sudo
          )
          
          # Add build-host if specified
          if [[ -n "$build_host" ]]; then
            cmd+=(--build-host "$build_host")
          fi
          
          # Add extra arguments
          cmd+=("''${extra_args[@]}")
          
          echo "Running: ''${cmd[@]}"
          "''${cmd[@]}"
        '';

        # Helper scripts for common deployment patterns
        deploy-remote = pkgs.writeShellScriptBin "deploy-remote" ''
          # Build on target host (remote build)
          ${self.packages.${system}.rb}/bin/rb "$1" --remote-build "''${@:2}"
        '';

        deploy-local = pkgs.writeShellScriptBin "deploy-local" ''
          # Build on local machine
          ${self.packages.${system}.rb}/bin/rb "$1" --local-build "''${@:2}"
        '';

        deploy-cross = pkgs.writeShellScriptBin "deploy-cross" ''
          # Build on different host than target
          if [ $# -lt 3 ]; then
            echo "Usage: deploy-cross TARGET_HOST BUILD_HOST [EXTRA_ARGS]"
            exit 1
          fi
          target_host=$1
          build_host=$2
          ${self.packages.${system}.rb}/bin/rb "$target_host" --build-host="$build_host" "''${@:3}"
        '';
      };

      # Development shell with deployment tools
      devShells.${system}.default = pkgs.mkShell {
        buildInputs = [
          self.packages.${system}.rb
          self.packages.${system}.deploy-remote
          self.packages.${system}.deploy-local
          self.packages.${system}.deploy-cross
          pkgs.nix
        ];
        
        shellHook = ''
          echo "Available deployment commands:"
          echo "  rb [host] [options]          - Flexible deployment (replacement for deploy-rs)"
          echo "  deploy-remote [host]         - Build on target host"
          echo "  deploy-local [host]          - Build on local machine"
          echo "  deploy-cross [target] [build] - Cross-host deployment"
          echo ""
          echo "Examples:"
          echo "  rb cedar --local-build -- --show-trace"
          echo "  deploy-remote oak"
          echo "  deploy-local fern"
          echo "  deploy-cross pine oak"
        '';
      };
    };
}