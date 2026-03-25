{ lib
, pkgs
}:

let
  pname = "tock-ui";
  name = "Tock UI";
  version = "1.13.0";

  src = pkgs.fetchurl {
    url = "https://github.com/DiiageCUCDB/tockApplicationCRA/releases/download/v${version}/Tock.UI_${version}_amd64.AppImage";
    hash = "sha256-4cSVEPVVqC2/dU7IyUEFds9jLVDn1GxsIwxIDRjxTHc=";
  };

  appimageContents = pkgs.appimageTools.extractType2 {
    inherit pname src version;
  };
in
pkgs.appimageTools.wrapType2 {
  inherit pname src version;

  # Use system libraries instead of AppImage bundled ones
  extraPkgs = pkgs: with pkgs; [
    glib
    gtk3
    gsettings-desktop-schemas
    hicolor-icon-theme
  ];

  extraInstallCommands = ''
    # Install desktop file
    install -m 444 -D "${appimageContents}/Tock UI.desktop" "$out/share/applications/${pname}.desktop"

    # Install icon
    install -m 444 -D "${appimageContents}/usr/share/icons/hicolor/128x128/apps/tock-ui.png" \
      "$out/share/icons/hicolor/512x512/apps/${pname}.png"
  '';
  
  meta = with lib; {
    description = "Tock UI application";
    homepage = "https://github.com/DiiageCUCDB/tockApplicationCRA";
    license = licenses.gpl3Only;
    maintainers = with maintainers; [];
    platforms = [ "x86_64-linux" ];
  };
}