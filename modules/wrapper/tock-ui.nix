{ lib
, fetchurl
, appimageTools
, gtk3
, gsettings-desktop-schemas
, glib
}:

let
  pname = "tock-ui";
  version = "1.13.0";
  hash = "sha256-4cSVEPVVqC2/dU7IyUEFds9jLVDn1GxsIwxIDRjxTHc=";
in

appimageTools.wrapType2 rec {
  inherit pname version;

  src = fetchurl {
    url = "https://github.com/DiiageCUCDB/tockApplicationCRA/releases/download/v${version}/Tock.UI_${version}_amd64.AppImage";
    name = "${pname}-${version}.AppImage";
    inherit hash;
  };

  # Use system libraries instead of AppImage bundled ones
  extraPkgs = pkgs: with pkgs; [
    glib
    gtk3
    gsettings-desktop-schemas
  ];

  extraInstallCommands = let
    contents = appimageTools.extractType2 { inherit pname version src; };
  in ''
    # Only copy non-library files
    mkdir -p "$out/share/applications"
    
    # Copy desktop file
    if ls "${contents}"/*.desktop 1>/dev/null 2>&1; then
      cp "${contents}"/*.desktop "$out/share/applications/${pname}.desktop"
      substituteInPlace "$out/share/applications/${pname}.desktop" \
        --replace 'Exec=AppRun' 'Exec=${pname}' \
        --replace 'Icon=${pname}' "Icon=${pname}" 2>/dev/null
    fi
  '';

  meta = with lib; {
    description = "Tock UI application";
    homepage = "https://github.com/DiiageCUCDB/tockApplicationCRA";
    license = licenses.unfree;
    maintainers = with maintainers; [];
    platforms = [ "x86_64-linux" ];
  };
}