{
  pkgs,
  config,
  lib,
  ...
}:

let
  cfg = config.modules.system.dev.dev-global;
in
{
  options.modules.system.dev.dev-global = {
    enable = lib.mkEnableOption "Enable global development tools and libraries";
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
      ];
    };
  };
}
