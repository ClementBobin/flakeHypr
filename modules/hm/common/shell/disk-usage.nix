{ pkgs, lib, config, ... }:

let
  cfg = config.modules.hm.shell.disk-usage;

  # Map disk usage tools to their packages
  toolToPackage = with pkgs; {
    ncdu = ncdu;
    gdu = gdu;
    dust = dust;
    parallel-disk-usage = parallel-disk-usage;
    squirreldisk = squirreldisk;
  };

  # Get packages for enabled tools
  toolPackages = lib.filter (pkg: pkg != null)
    (map (tool: toolToPackage.${tool} or null) cfg.tools);

in {
  options.modules.hm.shell.disk-usage = {
    tools = lib.mkOption {
      type = lib.types.listOf (lib.types.enum (lib.attrNames toolToPackage));
      default = [];
      description = "List of disk usage analyzers to install";
    };
  };

  config = {
    home.packages = toolPackages;
  };
}