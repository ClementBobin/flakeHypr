{ pkgs ? import <nixpkgs> {} }:

let
  pname = "nexis";
  version = "2.2.11";

  # Select architecture (x86_64 or aarch64)
  src = pkgs.fetchurl {
      url = "https://github.com/s4solutionsllc/nexis/releases/download/v${version}/Nexis-${version}-x86_64.AppImage";
      sha256 = "77799758d2aedcc98517295212c7831a3aa76a8ead699bf0982edd9a3f662332";
    };

  appimageContents = pkgs.appimageTools.extract { inherit pname version src; };

  nexis-app = pkgs.appimageTools.wrapType2 {
    inherit pname version src;
  };
in
pkgs.mkShell {
  buildInputs = [ nexis-app ];

  shellHook = ''
    echo "--- Nexis v${version} Shell ---"
    echo "Type 'nexis' to start the application."
  '';
}