{ pkgs, lib, config, ... }:

let
  # Shorthand for accessing module config
  cfg = config.modules.hm.dev.languages.python;

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
  options.modules.hm.dev.languages.python = {
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
    shellTools.enable = lib.mkEnableOption "Enable shell tools for Python";
  };

  # Actual config if module is enabled
  config = lib.mkIf cfg.enable {
    # Install core packages and optional tools
    home = {
      packages =
        allPythonPackages
        ++ lib.optional cfg.pdm.enable pkgs.pdm
        ++ lib.optionals cfg.tools.enable [
          pkgs."python${cfg.defaultVersion}Packages".black
          pkgs."python${cfg.defaultVersion}Packages".flake8
          pkgs."python${cfg.defaultVersion}Packages".pytest
        ];

      # Shell aliases
      shellAliases = {
        py = "python";
        pyclean = "find . -type f -name '*.py[co]' -delete";
        pytest = "python -m pytest";
      };
    };
    programs = {
      poetry = {
        enable = cfg.poetry.enable;
        settings = {
          virtualenvs.create = true;
          virtualenvs.in-project = true;
        };
      };

      pyenv.enableZshIntegration = cfg.shellTools.enable;
      zsh.prezto.python.virtualenvAutoSwitch = cfg.shellTools.enable;
      pylint.enable = cfg.shellTools.enable;
    };
  };
}
