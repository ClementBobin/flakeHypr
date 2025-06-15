{ pkgs, lib, config, ... }:

let
  cfg = config.modules.hm.dev.global-tools;

  # Map CLI tools to their packages
  cliToPackage = with pkgs; {
    vercel = nodePackages.vercel;
    graphite = graphite-cli;
  };

  # Get packages for enabled CLI tools
  cliPackages = lib.filter (pkg: pkg != null)
    (map (tool: cliToPackage.${tool} or null) cfg.cli);

in
{
  options.modules.hm.dev.global-tools = {
    cli = lib.mkOption {
      type = lib.types.listOf (lib.types.enum ["vercel" "graphite"]);
      default = [];
      description = "List of CLI tools to install";
    };
  };

  config = {
    home.packages = cliPackages;
  };
}