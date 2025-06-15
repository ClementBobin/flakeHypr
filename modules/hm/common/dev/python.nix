{ pkgs, lib, config, ... }:

let
  # Shorthand for accessing module config
  cfg = config.modules.hm.dev.python;

  # add home directory to devShell.shellPaths if not already present
  homePath = cfg.devShell.defaultPath; # or: builtins.toString config.home.homeDirectory
  devShellPaths = lib.unique (
    (lib.optionals (cfg.devShell.shellPaths == []) [ homePath ])
    ++ cfg.devShell.shellPaths
  );

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

  # Template for shell.nix content
  shellNixText = ''
    let
      pkgs = import <nixpkgs> {};
      python = pkgs.${"python" + cfg.defaultVersion};
    in
    pkgs.mkShell {
      buildInputs = [
        python
        python.pkgs.pip
        python.pkgs.pipx
        ${lib.concatMapStringsSep "\n      " (pkg: "python.pkgs.${pkg}") cfg.extraPackages}
      ];

      shellHook = '''
        if [ -f "pyproject.toml" ] || [ -f "requirements.txt" ]; then
          if [ ! -d ".venv" ]; then
            echo "🔧 No .venv found. Creating it..."
            python -m venv .venv
          fi

          source .venv/bin/activate
          echo "🐍 Activated .venv"
        else
          echo "⚠️ No pyproject.toml or requirements.txt found, skipping .venv auto-activation."
        fi
      ''';
    }
  '';

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

    # Dev shell generation
    devShell = {
      enable = lib.mkEnableOption "Generate a shell.nix file";
      defaultPath = lib.mkOption {
        type = lib.types.str;
        default = "./Templates";
        description = "Default path for shell.nix generation";
      };

      # Additional paths to generate shell.nix in (besides $HOME)
      shellPaths = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [];
        description = "Additional relative paths to create shell.nix (besides home)";
      };
    };
  };

  # Actual config if module is enabled
  config = lib.mkIf cfg.enable {
    # Install core packages and optional tools
    home.packages =
      allPythonPackages
      ++ lib.optional cfg.poetry.enable pkgs.poetry
      ++ lib.optional cfg.pdm.enable pkgs.pdm
      ++ lib.optionals cfg.tools.enable [
        pkgs."python${cfg.defaultVersion}Packages".black
        pkgs."python${cfg.defaultVersion}Packages".flake8
        pkgs."python${cfg.defaultVersion}Packages".pytest
      ];

    # Files to write to the home directory
    home.file = lib.mkMerge (
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
      ++
      (lib.optionals cfg.devShell.enable (
        map (path: {
          "${path}/shell.nix" = {
            text = shellNixText;
            force = true;
            mutable = true;
          };
        }) devShellPaths
      ))
    );
  };
}
