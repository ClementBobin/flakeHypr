{ pkgs, lib, config, ... }:

let
  cfg = config.modules.common.dev.node.graphite;
in
{
  options.modules.common.dev.node.graphite = {
    enable = lib.mkEnableOption "Enable Graphite CLI for Node.js";
  };

  config = lib.mkIf cfg.enable {
    home.packages = (with pkgs; [
      graphite-cli
    ]);
  };
}
