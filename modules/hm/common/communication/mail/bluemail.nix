{ pkgs, config, lib, ... }:
let
  cfg = config.modules.common.communication.mail.bluemail;

  bluemail = pkgs.bluemail;

  bluemailWithGPU = pkgs.symlinkJoin {
    name = "bluemail-with-gpu";
    paths = [ bluemail ];
    buildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      rm $out/bin/bluemail
      makeWrapper ${bluemail}/bin/bluemail $out/bin/bluemail --add-flags "--in-process-gpu"
    '';
  };

in {
  options = {
    modules.common.communication.mail.bluemail = {
      enable = lib.mkEnableOption "Enable BlueMail email client with GPU support";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ bluemailWithGPU ];
  };
}