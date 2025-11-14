{ lib, stdenv, fetchFromGitHub, cmake, pkg-config, qt6, wayland, hyprland, vulkan-headers }:

stdenv.mkDerivation rec {
  pname = "hyprdisplays";
  version = "0.1.240";

  src = fetchFromGitHub {
    owner = "ryzendew";
    repo = "HyprDisplays";
    rev = "v${version}";
    sha256 = "sha256-BvJSU+FHCD6MsBkxgP/P/sQe/mFNJ9ClV9UKLWart1s=";
  };

  nativeBuildInputs = [
    cmake
    pkg-config
    qt6.wrapQtAppsHook
  ];

  buildInputs = [
    qt6.qtbase
    qt6.qttools
    vulkan-headers
  ];

  cmakeFlags = [
    "-DCMAKE_BUILD_TYPE=Release"
  ];

  meta = with lib; {
    description = "Qt6-based graphical utility for arranging and configuring monitors for Hyprland";
    homepage = "https://github.com/ryzendew/HyprDisplays";
    license = licenses.mit;
    maintainers = with maintainers; [];
    platforms = platforms.linux;
    mainProgram = "hyprdisplays";
  };
}