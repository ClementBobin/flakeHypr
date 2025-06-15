{ pkgs, lib, config, ... }:

let
  cfg = config.modules.hm.dev.node.pm2;
in
{
  options.modules.hm.dev.node.pm2 = {
    enable = lib.mkEnableOption "Enable PM2 process manager for Node.js applications";
  };

  config = lib.mkIf cfg.enable {
    home.packages = (with pkgs; [
      pm2
    ]);
  };
}
