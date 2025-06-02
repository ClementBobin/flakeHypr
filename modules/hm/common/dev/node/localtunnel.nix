{ pkgs, lib, config, ... }:

let
  cfg = config.modules.common.dev.node.localtunnel;
in
{
  options.modules.common.dev.node.localtunnel = {
    enable = lib.mkEnableOption "Enable LocalTunnel for Node.js development";
  };

  config = lib.mkIf cfg.enable {
    home.packages = (with pkgs; [
      nodePackages.localtunnel
    ]);
  };
}
