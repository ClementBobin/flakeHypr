{ pkgs, lib, config, ... }:

let
  cfg = config.modules.hm.shell.fzf;
in
{
  options.modules.hm.shell.fzf = {
    enable = lib.mkEnableOption "Enable FZF (fuzzy finder)";
  };

  config.home.packages = (with pkgs; [
    fzf
  ]);
}
