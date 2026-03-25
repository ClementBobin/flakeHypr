{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.modules.hm.utilities.tracker;
  tockPkg = pkgs.callPackage ../../../wrapper/tock.nix {};
  tockUiPkg = pkgs.callPackage ../../../wrapper/tock-ui.nix {};
in {
  options.modules.hm.utilities.tracker = {
    enable = mkEnableOption "tock time tracking tool";

    package = mkOption {
      type = types.package;
      default = tockPkg;
      example = literalExpression "pkgs.tock";
      description = mdDoc ''
        The Tock package to use. This allows overriding the default
        package with a custom version or build.

        Defaults to the Tock package defined in this module.
      '';
    };

    ui = {
      package = mkOption {
        type = types.package;
        default = tockUiPkg;
        example = literalExpression "pkgs.tock-ui";
        description = mdDoc ''
          The Tock UI package to use. This allows overriding the default
          package with a custom version or build.

          Defaults to the Tock UI package defined in this module.
        '';
      };
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Whether to install the Tock UI application";
      };
    };
    
    backend = mkOption {
      type = types.enum [ "file" "timewarrior" ];
      default = "file";
      description = "Storage backend to use";
    };
    
    filePath = mkOption {
      type = types.nullOr types.str;
      default = "$HOME/.tock.txt";
      description = "Path to the tock file when using file backend";
    };

    alliasEnable = mkOption {
      type = types.bool;
      default = true;
      description = "Whether to enable the 'tock' alias in the shell";
    };
  };

  config = mkIf cfg.enable {
    home.packages = [
      cfg.package
      (mkIf cfg.ui.enable cfg.ui.package)
    ];

    home.sessionVariables = {
      TOCK_BACKEND = cfg.backend;
      TOCK_FILE = cfg.filePath;
    };

    home.shellAliases = mkIf cfg.alliasEnable {
      project-start = "tock start -p \"$1\" -d \"$2\"";
      project-stop = "tock stop";
      task-start = "tock start -t \"$1\" -d \"$2\"";
      task-stop = "tock stop";
      project-history = "tock last";
      task-history = "tock last -t \"$1\"";
      project-calendar = "tock calendar";
      task-calendar = "tock calendar";
      task-report = "tock report";
      project-report = "tock report";
    };
  };
}