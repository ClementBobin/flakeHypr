{ pkgs, lib, config, ... }:

let
  cfg = config.modules.hm.dev.global-tools.cli;

  # Map CLI tools to their packages
  cliToPackage = with pkgs; {
    vercel = nodePackages.vercel;
    graphite = graphite-cli;
  };

  # Get packages for enabled CLI tools
  cliPackages = lib.filter (pkg: pkg != null)
    (map (tool: cliToPackage.${tool} or null) cfg.elements);

in
{
  options.modules.hm.dev.global-tools.cli = {
    elements = lib.mkOption {
      type = lib.types.listOf (lib.types.enum ["vercel" "graphite"]);
      default = [];
      description = "List of CLI tools to install";
    };
  };

  config = {
    home.packages = cliPackages;
  };
}