{ lib, stdenv, rustPlatform, fetchCrate, pkg-config, openssl, sqlite, dbus }:

rustPlatform.buildRustPackage rec {
  pname = "wrkflw";
  version = "0.7.0";

  src = fetchCrate {
    inherit pname version;
    hash = "sha256-CeNZ5jb+8vtrXcn4d/UVcS0q2m+k9UgbPYSj6STGZ4k=";
  };

  cargoHash = "sha256-4xPuQdVMF6INYoxZkRIreJ5PUbEwa8FEIEmD2jV6v5g=";

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ openssl sqlite dbus ];

  meta = with lib; {
    description = "A tool for working with GitHub Actions workflows locally";
    homepage = "https://github.com/bahdotsh/wrkflw";
    license = licenses.mit;
    maintainers = with maintainers; [ ];
    platforms = platforms.all;
  };
}