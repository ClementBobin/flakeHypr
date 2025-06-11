{ pkgs, lib, config, ... }:

let
  cfg = config.modules.common.dev.node;

  npmGlobalPath = lib.replaceStrings ["~"] [config.home.homeDirectory] cfg.npmGlobalPrefix;

  # Function to get node + package manager for a given version
  nodeWithPackageManager = version: let
    nodeAttr = "nodejs_${version}";

    # Validate that the Node.js version exists
    nodePkg = if builtins.hasAttr nodeAttr pkgs
      then pkgs.${nodeAttr}
      else throw "Node.js version ${version} not available in nixpkgs";

    managerPkg = {
      pnpm = pkgs.pnpm;
      yarn = pkgs.yarn;
      npm = nodePkg; # included with node
    }.${cfg.packageManager};
  in [
    nodePkg
    managerPkg
  ];

  allNodePackages = lib.flatten (map nodeWithPackageManager cfg.versions) ++ (map (pkgName: pkgs.${pkgName}) cfg.extraPackages);
in
{
  options.modules.common.dev.node = {
    enable = lib.mkEnableOption "Enable Node.js development environment";
    packageManager = lib.mkOption {
      type = lib.types.enum [ "pnpm" "yarn" "npm" ];
      default = "pnpm";
      description = "Package manager to use for Node.js development";
    };
    versions = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ "20" ];
      description = "List of Node.js versions to install (e.g. ["18" "20"])";
    };

    extraPackages = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = [];
      description = "Additional node packages to install; need to specify nodePackages.{name of package}";
    };

    allowGlobalInstalls = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Whether to allow global package installations via npm/yarn/pnpm";
    };

    npmGlobalPrefix = lib.mkOption {
      type = lib.types.str;
      default = "~/.npm-global";
      description = "Directory for npm global installations";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = allNodePackages;

    home.activation = lib.mkIf cfg.allowGlobalInstalls {
      createNpmGlobalDir = lib.hm.dag.entryAfter ["writeBoundary"] ''
        mkdir -p "${npmGlobalPath}/bin"
      '';
    };

    home.shellAliases = lib.mkIf cfg.allowGlobalInstalls {
      npm-g = "npm install --global";
      pnpm-g = "pnpm add --global";
      yarn-g = "yarn global add";
    };
  };
}
