{
  pkgs,
  config,
  lib,
  ...
}:

let
  cfg = config.modules.dev-global;
in
{
  options.modules.dev-global = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable dev global";
    };
  };

  config = lib.mkIf cfg.enable {

    # Nix-ld
    programs.nix-ld = {
      enable = true;
      libraries = with pkgs; [
        # Add common dynamic libraries that programs might need
        stdenv.cc.cc
        openssl
        curl
        glib
        util-linux
        glibc
        icu
        libunwind
        libuuid
        zlib
        # Add any other libraries you might need

        # Node.js dependencies
        nodejs_20
        nodePackages.pnpm
        # Common runtime dependencies
        stdenv.cc.cc
        openssl
        zlib
        pnpm
      ];
    };
  };
}
