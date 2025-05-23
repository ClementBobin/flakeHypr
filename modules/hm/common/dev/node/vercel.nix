{ pkgs, lib, config, ... }:

let
  cfg = config.modules.common.dev.node.vercel;
in
{
  options.modules.common.dev.node.vercel = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable vercel for node development environment";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = (with pkgs; [
      nodePackages.vercel
    ]);
  };
}
