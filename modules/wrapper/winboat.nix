{ lib
, fetchurl
, appimageTools
}:

let
  pname = "winboat";
  version = "0.8.7";
  hash = "sha256-XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX=";
in

appimageTools.wrapType2 rec {
  inherit pname version;

  src = fetchurl {
    url = "https://github.com/TibixDev/winboat/releases/download/v${version}/Winboat-${version}.AppImage";
    name = "${pname}-${version}.AppImage";
    inherit hash;
  };

  extraInstallCommands = let
    contents = appimageTools.extractType2 { inherit pname version src; };
  in ''
    mkdir -p "$out/share/applications"
    mkdir -p "$out/share/lib/${pname}"
    cp -r ${contents}/{locales,resources} "$out/share/lib/${pname}" || true
    cp -r ${contents}/usr/* "$out" || true
    cp "${contents}/${pname}.desktop" "$out/share/applications/" 2>/dev/null || true
    substituteInPlace "$out/share/applications/${pname}.desktop" --replace 'Exec=AppRun' 'Exec=${pname}' 2>/dev/null || true
  '';

  meta = with lib; {
    description = "A lightweight application to run Windows applications on Linux using Wine";
    homepage = "https://github.com/TibixDev/winboat";
    license = licenses.gpl3Only;
    maintainers = with maintainers; [ ];
    platforms = [ "x86_64-linux" ];
  };
}