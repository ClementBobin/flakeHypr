{ pkgs, lib, config, ... }:

let
  cfg = config.modules.common.dev.node.localtunnel;
in
{
  options.modules.common.dev.node.localtunnel = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable localtunnel for node development environment";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = (with pkgs; [
      nodePackages.localtunnel
    ]);
  };
}
