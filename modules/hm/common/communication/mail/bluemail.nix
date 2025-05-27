{ pkgs, config, lib, ... }:
let
  cfg = config.modules.common.communication.mail.bluemail;

  bluemail = pkgs.bluemail;

  bluemailWithGPU = pkgs.stdenv.mkDerivation {
  name = "bluemail-with-gpu";
  phases = [ "installPhase" ];
  buildInputs = [ pkgs.makeWrapper ];
  installPhase = ''
    mkdir -p $out/bin
    cp -r ${bluemail}/* $out/
    substituteInPlace $out/share/applications/bluemail.desktop \
      --replace "Exec=bluemail" "Exec=bluemail-gpu"
    makeWrapper ${bluemail}/bin/bluemail $out/bin/bluemail-gpu --add-flags "--in-process-gpu"
  '';
};

in {
  options = {
    modules.common.communication.mail.bluemail.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable the bluemail emailclient.";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [ bluemailWithGPU ];
  };
}
