{ pkgs, lib, config, ... }:

let
  cfg = config.modules.hm.security.burp;
in
{
  options.modules.hm.security.burp = {
    enable = lib.mkEnableOption "Enable Burp Suite Community Edition";
  };

  config = lib.mkIf cfg.enable {
    home.packages = (with pkgs; [
      burpsuite
    ]);
  };
}
