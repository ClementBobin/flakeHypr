{ pkgs, lib, config, ... }:

let
  cfg = config.modules.common.dev.node;
in
{
  options.modules.common.dev.node = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable node development environment";
    };

    installMethod = lib.mkOption {
      type = lib.types.enum [ "hm" "sys" ];
      default = "hm";
      description = "Choose whether to install node-related tools via home-manager or directly in the environment.";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = lib.mkIf (cfg.installMethod == "hm") (with pkgs; [
      nodePackages.pnpm
      nodejs_20
      nodePackages.vercel
      graphite-cli
    ]);
  };
}
