{ pkgs, lib, config, ... }:

let
  cfg = config.modules.common.dev.python;

  pythonWithPipx = version: let
    pythonAttr = "python${version}";
    pythonPkg = pkgs.${pythonAttr};
    pythonPkgsAttr = "${pythonAttr}Packages";
    pythonPkgs = pkgs.${pythonPkgsAttr};
  in if version == "312" && config.hydenix.hm.enable then
    [ pythonPkgs.pipx pythonPkgs.pip ]
  else
    [
      pythonPkg
      pythonPkgs.pipx
      pythonPkgs.pip
    ];

  allPythonPackages = lib.flatten (map pythonWithPipx cfg.versions);
in
{
  options.modules.common.dev.python = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable Python development environment";
    };

    versions = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ "312" ]; # e.g. "311", "310"
      description = "List of Python versions to install (e.g., ["311" "312"])";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = allPythonPackages;
  };
}
