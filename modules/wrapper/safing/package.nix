{ lib, stdenv, fetchurl, dpkg, autoPatchelfHook, makeWrapper, glib, gtk3, cairo
, pango, gdk-pixbuf, atk, webkitgtk_4_1, libsoup_3, openssl, curl, systemd
, iptables, iproute2, xorg, alsa-lib, nss, nspr, at-spi2-atk, cups, dbus, expat
, fontconfig, freetype, zlib, pkgs, libayatana-appindicator }:

stdenv.mkDerivation rec {
  pname = "portmaster";
  version = "2.0.22";
  src = fetchurl {
    url = "https://updates.safing.io/latest/linux_amd64/packages/Portmaster_${version}_amd64.deb";
    sha256 = "sha256-D0fpXVM6X3pxZozh6bXvvpu4K7hI4sq9SXhvQGvr0Go=";
  };

  nativeBuildInputs = [ dpkg autoPatchelfHook makeWrapper pkgs.unzip ];

  buildInputs = [
    glib
    gtk3
    cairo
    pango
    gdk-pixbuf
    atk
    webkitgtk_4_1
    libsoup_3
    openssl
    curl
    systemd
    xorg.libX11
    xorg.libXcomposite
    xorg.libXcursor
    xorg.libXdamage
    xorg.libXext
    xorg.libXfixes
    xorg.libXi
    xorg.libXrender
    xorg.libXtst
    xorg.libXrandr
    xorg.libXScrnSaver
    xorg.libxcb
    alsa-lib
    nss
    nspr
    at-spi2-atk
    cups
    dbus
    expat
    fontconfig
    freetype
    zlib
    libayatana-appindicator
  ];

  unpackPhase = ''
    runHook preUnpack
    dpkg-deb -x $src .
    runHook postUnpack
  '';

installPhase = ''
    runHook preInstall

    # Create directories matching AUR structure
    mkdir -p $out/usr/lib/portmaster
    mkdir -p $out/bin
    mkdir -p $out/usr/lib/systemd/system
    mkdir -p $out/var/lib/portmaster/intel

    # Install core binary in usr/lib/portmaster
    install -m755 usr/lib/portmaster/portmaster-core $out/usr/lib/portmaster/

    # Install GUI binary from usr/bin to usr/lib/portmaster (AUR structure)
    install -m755 usr/bin/portmaster $out/usr/lib/portmaster/

    # Install archives in usr/lib/portmaster
    install -m644 usr/lib/portmaster/portmaster.zip $out/usr/lib/portmaster/
    install -m644 usr/lib/portmaster/assets.zip $out/usr/lib/portmaster/

    # Create symlinks in bin for PATH access
    ln -s $out/usr/lib/portmaster/portmaster-core $out/bin/portmaster-core
    ln -s $out/usr/lib/portmaster/portmaster $out/bin/portmaster

    # Copy data files
    cp -r var/lib/portmaster/intel/* $out/var/lib/portmaster/intel/

    # Copy desktop files and icons
    mkdir -p $out/share/applications
    mkdir -p $out/share/icons
    cp usr/share/applications/Portmaster.desktop $out/share/applications/
    cp -r usr/share/icons/* $out/share/icons/

    # Copy autostart file
    mkdir -p $out/share/autostart
    cp etc/xdg/autostart/portmaster.desktop $out/share/autostart/

    cp usr/lib/systemd/system/portmaster.service $out/usr/lib/systemd/system/

    runHook postInstall
  '';

  postFixup = ''
    # Wrap binaries in their actual location (usr/lib/portmaster)
    for binary in $out/usr/lib/portmaster/portmaster*; do
      if [ -f "$binary" ] && [ -x "$binary" ]; then
        echo "Wrapping binary: $binary"
        wrapProgram "$binary" \
          --prefix PATH : ${
            lib.makeBinPath [ systemd iptables iproute2 pkgs.coreutils ]
          } \
          --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath buildInputs}
      fi
    done
  '';

  meta = with lib; {
    description = "Portmaster - Privacy Protection Tool";
    homepage = "https://safing.io/portmaster/";
    license = licenses.agpl3Plus;
    platforms = platforms.linux;
    maintainers = with maintainers; [ WitteShadovv ];
    sourceProvenance = with sourceTypes; [ binaryNativeCode ];
  };
}