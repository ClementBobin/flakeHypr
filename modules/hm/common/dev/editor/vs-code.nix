{ config, lib, pkgs, vars, ... }:

let
  cfg = config.modules.common.dev.editor.vs-code;
in
{
    # Add options for vs-code
    options.modules.common.dev.editor.vs-code = {
        enable = lib.mkOption {
            type = lib.types.bool;
            default = false;
            description = ''
                Enable vs-code.
            '';
        };
    };

    # VS Code configuration, conditional on vs-code.enable
    config = lib.mkIf cfg.enable {
        programs.vscode = {
            enable = true;
        };
    };
}