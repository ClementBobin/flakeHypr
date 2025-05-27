{ pkgs, lib, config, ... }:

let
  cfg = config.modules.common.dev.node.pm2;
in
{
  options.modules.common.dev.node.pm2 = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable pm2 for node development environment";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = (with pkgs; [
      pm2
    ]);
  };
}
