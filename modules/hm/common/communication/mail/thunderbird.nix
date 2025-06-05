{ pkgs, lib, config, ... }:

let
  cfg = config.modules.common.communication.mail.thunderbird;
in
{
  options.modules.common.communication.mail.thunderbird = {
    enable = lib.mkEnableOption "Enable Thunderbird email client";
  };

  config = lib.mkIf cfg.enable {
    home.packages = (with pkgs; [
      thunderbird-latest
    ]);
  };
}
