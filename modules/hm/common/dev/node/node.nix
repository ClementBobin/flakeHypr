{ pkgs, lib, config, ... }:

let
  cfg = config.modules.common.dev.node;

  # Function to get node + package manager for a given version
  nodeWithPackageManager = version: let
    nodeAttr = "nodejs_${version}";
    nodePkg = pkgs.${nodeAttr};

    managerPkg = {
      pnpm = pkgs.pnpm;
      yarn = pkgs.yarn;
      npm = nodePkg; # included with node
    }.${cfg.package-manager};
  in [
    nodePkg
    managerPkg
  ];

  allNodePackages = lib.flatten (map nodeWithPackageManager cfg.versions);
in
{
  options.modules.common.dev.node = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable Node.js development environment";
    };
    package-manager = lib.mkOption {
      type = lib.types.enum [ "pnpm" "yarn" "npm" ];
      default = "pnpm";
      description = "Package manager to use for Node.js development";
    };
    versions = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ "20" ];
      description = "List of Node.js versions to install (e.g. ["18" "20"])";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = allNodePackages;
  };
}
