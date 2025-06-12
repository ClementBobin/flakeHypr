{ pkgs, config, lib, ... }:
let
  cfg = config.modules.common.communication.mail.bluemail;

  bluemail = pkgs.bluemail;

  bluemailWithGPU = pkgs.symlinkJoin {
    name = "bluemail-with-gpu";
    paths = [ bluemail ];
    nativeBuildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      rm -f $out/bin/bluemail
      makeWrapper ${bluemail}/bin/bluemail $out/bin/bluemail --add-flags "--in-process-gpu"
    '';
  };

in {
  # export for other module
  bluemailWithGPU = bluemailWithGPU;
}