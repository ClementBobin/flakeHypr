{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.modules.common.utilities.scalar;

  scalar-deb = pkgs.fetchurl {
    url = "https://download.scalar.com/linux/deb/x64";
    sha256 = "sha256-R/pf8Df3qYufiDKwTJLEztfcqJ9/+nXclHQqQi+uF3A=";
  };

  scalar-app = pkgs.stdenv.mkDerivation {
    name = "scalar-desktop";
    src = scalar-deb;

    nativeBuildInputs = [ pkgs.autoPatchelfHook pkgs.dpkg pkgs.makeWrapper ];
    buildInputs = with pkgs; [
      alsa-lib
      mesa
      libdrm
      libglvnd
      vulkan-loader
      libva
      gtk3
      libsecret
      nss
      xorg.libXdamage
      xorg.libXtst
      xorg.libXcomposite
      xorg.libXrandr
    ];

    unpackPhase = "dpkg -x $src .";

    installPhase = ''
      # Install application
      mkdir -p $out/opt/Scalar
      cp -r opt/Scalar/* $out/opt/Scalar/

      # Install desktop file and icons from usr/share
      mkdir -p $out/share
      cp -r usr/share/* $out/share/

      # Fix the Exec path in the desktop file
      substituteInPlace $out/share/applications/scalar-app.desktop \
        --replace "Exec=/opt/Scalar/scalar-app" "Exec=$out/bin/scalar-desktop"

      # Create binary wrapper with proper library paths
      mkdir -p $out/bin
      makeWrapper $out/opt/Scalar/scalar-app $out/bin/scalar-desktop \
        --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath (with pkgs; [
          alsa-lib
          mesa
          libdrm
          libglvnd
          vulkan-loader
          libva
        ])} \
        --prefix PATH : ${lib.makeBinPath [ pkgs.xorg.xrandr ]}
    '';
  };

in {
  options.modules.common.utilities.scalar = {
    enable = mkEnableOption "Scalar desktop application";
  };

  config = mkIf cfg.enable {
    home.packages = [ scalar-app ];
    xdg.enable = true;
  };
}