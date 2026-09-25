{
  description = "template for hydenix";

  inputs = {
    # User's nixpkgs - for user packages
    nixpkgs = {
      # url = "github:nixos/nixpkgs/nixos-unstable"; # uncomment this if you know what you're doing
      follows = "hydenix/nixpkgs";
    };
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    nix-gaming.url = "github:fufexan/nix-gaming";

    # Hydenix and its nixpkgs - kept separate to avoid conflicts
    #hydenix.url = "path:/home/mirage/Documents/dev/multi-stack-project/nixos/hydenix";
    hydenix.url = "github:ClementBobin/hydenix/v1.18.0";
    nixos-hardware.url = "github:nixos/nixos-hardware/master";

    linux-wallpaper-engine.url = "github:jagrat7/linux-wallpaper-engine";
  };

  outputs = { self, ... }@inputs:
    let
      vars = {
        user = "mirage";
      };
      system = "x86_64-linux";

      # Create a function to generate host configurations
      mkHost = hostname: extraVars:
        let
          pkgs = import inputs.nixpkgs {
            inherit system;
            config = {
              allowUnfree = true;
              permittedInsecurePackages = [
                "electron-41.9.1"
                "electron-41.10.6"
              ];
            };
            overlays = [ inputs.hydenix.overlays.default ];
          };
        in
        inputs.nixpkgs.lib.nixosSystem {
          inherit system pkgs;
          specialArgs = {
            inherit inputs system;
            vars = vars // extraVars;
            pkgs-unstable = import inputs.nixpkgs-unstable {
              inherit system;
              config = {
                allowUnfree = true;
                permittedInsecurePackages = [ "electron-41.10.6" ];
              };
            };
          };
          modules = [
            ./hosts/${hostname}
          ];
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
        fern = self.nixosConfigurations.fern.config.system.build.toplevel;
        birch-seed = self.nixosConfigurations.birch-seed.config.system.build.toplevel;
        pine = self.nixosConfigurations.pine.config.system.build.toplevel;
        oak = self.nixosConfigurations.oak.config.system.build.toplevel;
        cedar = self.nixosConfigurations.cedar.config.system.build.toplevel;
      };
    };
}
