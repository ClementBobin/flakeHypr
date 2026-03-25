{ pkgs, lib }:

let
  name = "fluxer";
  type = "stable";
  version = "0.0.8";
  system = "x86_64";
  pname = name;

  src = pkgs.fetchurl {
    url = "https://api.fluxer.app/dl/desktop/stable/linux/x64/latest/appimage";
    hash = "sha256-GdoBK+Z/d2quEIY8INM4IQy5tzzIBBM+3CgJXQn0qAw=";
  };

  # Extract with the original complex name to avoid hash issues, but we'll reference contents carefully
  appimageContents = pkgs.appimageTools.extractType2 {
    pname = "${name}-${version}-${system}";
    inherit src version;
  };
in
pkgs.appimageTools.wrapType2 {
  # Use the simple pname for the wrapped app
  inherit pname src version;

  extraInstallCommands = ''
    # Install desktop file
    install -m 444 -D "${appimageContents}/${name}.desktop" "$out/share/applications/${pname}.desktop"

    # Install icon
    install -m 444 -D "${appimageContents}/usr/share/icons/hicolor/512x512/apps/${name}.png" \
      "$out/share/icons/hicolor/512x512/apps/${pname}.png"
  '';

  meta = with lib; {
    description = "Fluxer is an open-source, Discord-alternative, focused on privacy and security.";
    homepage = "https://fluxer.app/";
    license = licenses.gpl3;
    maintainers = [ ];
    platforms = [ "x86_64-linux" ];
  };
}