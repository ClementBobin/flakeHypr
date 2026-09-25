{ pkgs, lib, config, ... }:

let
  cfg = config.modules.hm.dev.tools.prisma;
in
{
  options.modules.hm.dev.tools.prisma = {
    enable = lib.mkEnableOption "Enable Prisma ORM for Node.js applications";
  };

  config = lib.mkIf cfg.enable {
    # Install shell tools via home-manager
    home.packages = (with pkgs; [
      prisma
    ]);

    home.sessionVariables = {
      PRISMA_SCHEMA_ENGINE_BINARY = "${pkgs.prisma-engines}/bin/schema-engine";
      PRISMA_QUERY_ENGINE_BINARY = "${pkgs.prisma-engines}/bin/query-engine";
      PRISMA_QUERY_ENGINE_LIBRARY = "${pkgs.prisma-engines}/lib/libquery_engine.node";
      PRISMA_FMT_BINARY = "${pkgs.prisma-engines}/bin/prisma-fmt";
      PRISMA_ENGINES_CHECKSUM_IGNORE_MISSING = 1;
    };
  };
}
