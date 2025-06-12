{ pkgs, lib, config, ... }:

let
  cfg = config.modules.common.shell.fzf;
in
{
  options.modules.common.shell.fzf = {
    enable = lib.mkEnableOption "Enable FZF (fuzzy finder)";
  };

  config.home.packages = (with pkgs; [
    fzf
  ]);
}
