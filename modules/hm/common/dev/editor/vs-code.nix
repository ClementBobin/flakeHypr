{ config, lib, pkgs, vars, ... }:

let
    cfg = config.modules.common.dev.editor.vs-code;
in
{
    # Add options for vs-code
    options.modules.common.dev.editor.vs-code = {
        enable = lib.mkEnableOption "Enable Visual Studio Code for development";
    };

    # VS Code configuration, conditional on vs-code.enable
    config = lib.mkIf cfg.enable {
        programs.vscode = {
            enable = true;
        };
    };
}