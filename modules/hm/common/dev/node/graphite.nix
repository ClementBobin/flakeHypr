{ pkgs, lib, config, ... }:

let
  cfg = config.modules.common.dev.node.graphite;
in
{
  options.modules.common.dev.node.graphite = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable graphite for node development environment";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = (with pkgs; [
      graphite-cli
    ]);
  };
}
