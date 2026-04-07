{
  appimageTools,
  lib,
  fetchurl,
  libthai,
  harfbuzz,
  fontconfig,
  freetype,
  libz,
  libX11,
  mesa,
  libdrm,
  fribidi,
  libxcb,
  libgpg-error,
  libGL,
  makeWrapper,
  dieHook,
}:
let
  pname = "viper";
  version = "1.13.0";

  capitalize =
    str:
    (lib.toUpper (builtins.substring 0 1 str))
    + ((builtins.substring 1 (builtins.stringLength str)) str);

  src = fetchurl {
    url = "https://github.com/0neGal/${pname}/releases/download/v${version}/${capitalize pname}-${version}.AppImage";
    hash = "sha256-UcOcWjRRVask1JNBMriGasCUAr9GQRXCzIwU5Sa0e00=";
    name = "${pname}-${version}.AppImage";
  };

  appimageContents = appimageTools.extractType2 {
    inherit pname version src;
  };

  libs = [
    libthai
    harfbuzz
    fontconfig
    freetype
    libz
    libX11
    mesa
    libdrm
    fribidi
    libxcb
    libgpg-error
    libGL
  ];
in
appimageTools.wrapType2 {
  inherit pname version src;
  multiPkgs = null; # no 32bit needed
  extraPkgs = p: (appimageTools.defaultFhsEnvArgs.multiPkgs p) ++ libs;
  extraInstallCommands = ''
    install -m 444 -D ${appimageContents}/${pname}.desktop -t $out/share/applications
    install -m 444 -D ${appimageContents}/usr/share/icons/hicolor/0x0/apps/${pname}.png \
      $out/share/icons/hicolor/256x256/apps/${pname}.png
    sed -i "s|Exec=AppRun|Exec=$out/bin/${pname}|" $out/share/applications/${pname}.desktop
  '';

  meta = {
    description = "Launcher+Updater for TF|2 Northstar ";
    homepage = "https://github.com/0neGal/viper";
    license = lib.licenses.gpl3Only;
    mainProgram = "viper";
    maintainers = with lib.maintainers; [ NotAShelf ];
    platforms = [ "x86_64-linux" ];
  };
}