{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.modules.common.utilities.scalar;

  scalar-source = pkgs.stdenv.mkDerivation {
    name = "scalar-desktop";
    src = pkgs.fetchurl {
      url = "https://download.scalar.com/linux/deb/x64";
      sha256 = "sha256-8OvULS7qo1rLyEHXnacsjQzkS/J3OEXwhvIDfoP7Hh8=";
    };

    nativeBuildInputs = [ pkgs.xz pkgs.gnutar ];

    unpackPhase = ''
      ar x $src
      tar -xf data.tar.xz

      mkdir -p $out
      cp -r opt usr $out/

      # Rename the exposed binary to avoid conflict with Git's `scalar`
      mkdir -p $out/bin
      ln -s $out/opt/Scalar/scalar-app $out/bin/scalar-api-desktop
    '';
  };

  scalarFHS = pkgs.buildFHSEnvBubblewrap {
    name = "scalar-desktop";
    targetPkgs = pkgs: with pkgs; [
      scalar-source
      dbus
      glib
      atk
      pango
      cairo
      gtk3
      xorg.libX11
      xorg.libXfixes
      xorg.libXcomposite
      xorg.libXdamage
      xorg.libXrandr
      xorg.libxcb
      xorg.libXext
      xorg.libxshmfence
      libxkbcommon
      alsa-lib
      libdrm
      mesa
      vulkan-loader
      nss
      nspr
      cups
      libpulseaudio
    ];
    runScript = "scalar-api-desktop";

    # (Optional) Volume bind for user home, if the app writes configs
    extraBwrapArgs = [ "--bind" "/home" "/home" ];
  };

in {
  options.modules.common.utilities.scalar = {
    enable = mkEnableOption "Scalar desktop application";
  };

  config = mkIf cfg.enable {
    home.packages = [ scalarFHS ];
  };
}
