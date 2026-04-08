{ lib, appimageTools, fetchurl }:

let
  pname = "nexis";
  version = "2.2.11";

  src = fetchurl {
    url = "https://github.com/s4solutionsllc/nexis/releases/download/v${version}/Nexis-${version}-x86_64.AppImage";
    sha256 = "77799758d2aedcc98517295212c7831a3aa76a8ead699bf0982edd9a3f662332";
  };

  # Extract the AppImage so we can grab the icon and desktop file
  appimageContents = appimageTools.extract {
    inherit pname version src;
  };

in appimageTools.wrapType2 {
  inherit pname version src;

  # This section moves the binary to a standard location and adds desktop integration
  extraInstallCommands = ''
    install -m 444 -D ${appimageContents}/${pname}.desktop $out/share/applications/${pname}.desktop
    install -m 444 -D ${appimageContents}/${pname}.png $out/share/icons/hicolor/512x512/apps/${pname}.png
    
    # Ensure the desktop file points to the wrapped binary, not the extracted path
    substituteInPlace $out/share/applications/${pname}.desktop \
      --replace 'Exec=AppRun' 'Exec=${pname}'
  '';

  meta = with lib; {
    description = "Nexis Client - Powerful automation and management tool";
    homepage = "https://github.com/s4solutionsllc/nexis";
    license = licenses.unfree;
    platforms = [ "x86_64-linux" ];
    mainProgram = "nexis";
  };
}