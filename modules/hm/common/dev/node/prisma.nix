{ pkgs, lib, config, ... }:

let
  cfg = config.modules.hm.dev.node.prisma;
in
{
  options.modules.hm.dev.node.prisma = {
    enable = lib.mkEnableOption "Enable Prisma ORM for Node.js applications";
  };

  config = lib.mkIf cfg.enable {
    # Install shell tools via home-manager
    home.packages = (with pkgs; [
      prisma
    ]);
  };
}
