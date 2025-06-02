{ pkgs, config, lib, ... }:
let
  cfg = config.modules.common.communication.mail.bluemail;

  bluemail = pkgs.bluemail;

  bluemailWithGPU = pkgs.stdenv.mkDerivation {
  name = "bluemail-with-gpu";
  phases = [ "installPhase" ];
  buildInputs = [ pkgs.makeWrapper ];
  bluemailWithGPU = pkgs.symlinkJoin {
    name = "bluemail-with-gpu";
    paths = [ bluemail ];
    buildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      rm $out/bin/bluemail
      makeWrapper ${bluemail}/bin/bluemail $out/bin/bluemail --add-flags "--in-process-gpu"
    '';
  };
};

in {
  options = {
    modules.common.communication.mail.bluemail = {
      enable = lib.mkEnableOption "Enable Bluemail without GPU support";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [ bluemailWithGPU ];
  };
}
