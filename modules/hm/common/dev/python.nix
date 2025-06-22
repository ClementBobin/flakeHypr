{ pkgs, lib, config, ... }:

let
  # Shorthand for accessing module config
  cfg = config.modules.hm.dev.python;

  # Function to get the required Python version with pipx, pip, and extra packages
  pythonWithPipx = version: let
    pythonAttr = "python${version}";
    pythonPkg = pkgs.${pythonAttr};
    pythonPkgsAttr = "${pythonAttr}Packages";
    pythonPkgs = pkgs.${pythonPkgsAttr};

    # Map extra package names to actual derivations
    extraPkgsMapped = map (pkg: pythonPkgs.${pkg}) cfg.extraPackages;
  in
    # Special case for Python 3.12 when using hydenix.hm
    # hydenix.hm already provides the Python 3.12 interpreter,
    # so only pipx and pip (plus extras) are needed here.
    if version == "312" && config.hydenix.hm.enable then
      [ pythonPkgs.pipx pythonPkgs.pip ] ++ extraPkgsMapped
    else
      [ pythonPkg pythonPkgs.pipx pythonPkgs.pip ] ++ extraPkgsMapped;

  # Flattened list of all selected Python versions with extras
  allPythonPackages = lib.flatten (map pythonWithPipx cfg.versions);

in {
  options.modules.hm.dev.python = {
    # Main toggle
    enable = lib.mkEnableOption "Enable Python development environment";

    # List of Python versions to install
    versions = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ "312" ];
      description = "Python versions to install";
    };

    # Default Python version for shell and aliases
    defaultVersion = lib.mkOption {
      type = lib.types.str;
      default = builtins.head cfg.versions;
      description = "Default Python version for the shell";
    };

    # Python packages (from pythonXXXPackages) to include
    extraPackages = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
      description = ''Extra Python packages (e.g., ["requests" "httpx"])'';
    };

    # Optional package toggles
    poetry.enable = lib.mkEnableOption "Install Poetry";
    pdm.enable = lib.mkEnableOption "Install PDM";
    tools.enable = lib.mkEnableOption "Install dev tools (pytest, black, flake8)";
  };

  # Actual config if module is enabled
  config = lib.mkIf cfg.enable {
    # Install core packages and optional tools
    home = {
      packages =
        allPythonPackages
        ++ lib.optional cfg.poetry.enable pkgs.poetry
        ++ lib.optional cfg.pdm.enable pkgs.pdm
        ++ lib.optionals cfg.tools.enable [
          pkgs."python${cfg.defaultVersion}Packages".black
          pkgs."python${cfg.defaultVersion}Packages".flake8
          pkgs."python${cfg.defaultVersion}Packages".pytest
        ];

      # Files to write to the home directory
      file = lib.mkMerge (
        [
          {
            ".config/profile.d/python-aliases.sh".text = ''
              export PATH=${pkgs."python${cfg.defaultVersion}"}/bin:$PATH
              alias py="python"
              alias pipx="pipx"
              alias pip="pip"
              alias pyclean="find . -type f -name '*.py[co]' -delete"
              alias pytest="python -m pytest"
            '';
          }
        ]
      );
      # Shell aliases
      shellAliases = {
        py = "python";
        pyclean = "find . -type f -name '*.py[co]' -delete";
        pytest = "python -m pytest";
      };
    };
  };
}
