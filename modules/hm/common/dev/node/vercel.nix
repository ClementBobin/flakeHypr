{ pkgs, lib, config, ... }:

let
  cfg = config.modules.common.dev.node.vercel;
in
{
  options.modules.common.dev.node.vercel = {
    enable = lib.mkEnableOption "Enable Vercel CLI for Node.js deployments";
  };

  config = lib.mkIf cfg.enable {
    home.packages = (with pkgs; [
      nodePackages.vercel
    ]);
  };
}
