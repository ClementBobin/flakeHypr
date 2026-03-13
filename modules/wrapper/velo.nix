{ lib, appimageTools, fetchurl }:

let
  pname = "velo";
  version = "0.4.21";

  src = fetchurl {
    url = "https://github.com/avihaymenahem/velo/releases/download/velo-v${version}/Velo_${version}_amd64.AppImage";
    hash = "sha256-T55mgJ6AVfHAcU8m5yIBf+8XXoKrIMV2aWwk8u3yRlg=";
  };

  # Extract the AppImage contents to get icons and desktop file
  appimageContents = appimageTools.extractType2 {
    inherit pname version src;
  };
in

appimageTools.wrapType2 {
  inherit pname version src;

  extraInstallCommands = ''
    # Install desktop file
    install -m 444 -D "${appimageContents}/Velo.desktop" "$out/share/applications/${pname}.desktop"

    # Install icon
    install -m 444 -D "${appimageContents}/usr/share/icons/hicolor/256x256@2/apps/velo.png" \
      "$out/share/icons/hicolor/512x512/apps/${pname}.png"
  '';

  meta = with lib; {
    description = "Blazing-fast, keyboard-first desktop email client built with Tauri, React, and Rust";
    homepage = "https://github.com/avihaymenahem/velo";
    license = licenses.asl20;
    maintainers = [ ];
    platforms = [ "x86_64-linux" ];
    mainProgram = "velo";
  };
}