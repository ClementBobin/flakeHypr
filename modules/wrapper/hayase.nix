{ lib
, fetchurl
, appimageTools
}:

let
  pname = "hayase";
  version = "6.4.50";
  hash = "sha256-7fXu8ySC8FioLA1PlyorS6F7Kv34nlo8Djhj54kCEOI=";
in

appimageTools.wrapType2 rec {
  inherit pname version;

  src = fetchurl {
    url = "https://api.hayase.watch/files/linux-hayase-${version}-linux.AppImage";
    name = "${pname}-${version}.AppImage";
    inherit hash;
  };

  extraInstallCommands = let
    contents = appimageTools.extractType2 { inherit pname version src; };
  in ''
    mkdir -p "$out/share/applications"
    mkdir -p "$out/share/lib/hayase"
    cp -r ${contents}/{locales,resources} "$out/share/lib/hayase"
    cp -r ${contents}/usr/* "$out"
    cp "${contents}/${pname}.desktop" "$out/share/applications/"
    substituteInPlace $out/share/applications/${pname}.desktop --replace 'Exec=AppRun' 'Exec=${pname}'
  '';

  meta = with lib; {
    description = "A bittorrent streaming application for anime";
    homepage = "https://hayase.watch/";
    license = licenses.gpl3Only;
    maintainers = with maintainers; [ ];
    platforms = [ "x86_64-linux" ];
  };
}