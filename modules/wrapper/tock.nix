{ lib, stdenv, fetchFromGitHub, buildGoModule }:

buildGoModule rec {
  pname = "tock";
  version = "0.8.5";

  src = fetchFromGitHub {
    owner = "kriuchkov";
    repo = "tock";
    rev = "v${version}";
    hash = "sha256-Qy49uZg8YWu+tdTNaY+mvX6ABx3LLNMTRo27wpHy0I4=";
  };

  vendorHash = "sha256-ZmONPbetDHReGF1wBX0BPI4d0cBc/ms/0EpjzW1PVVA=";

  ldflags = [ "-s" "-w" ];

  # Build just the main binary
  subPackages = [ "cmd/tock" ];

  meta = with lib; {
    description = "A powerful time tracking tool for the command line with interactive TUI";
    homepage = "https://github.com/kriuchkov/tock";
    license = licenses.gpl3Only;
    maintainers = with maintainers; [];
    platforms = platforms.unix;
    mainProgram = "tock";
  };
}