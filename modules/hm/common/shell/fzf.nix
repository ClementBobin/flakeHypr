{ pkgs, lib, config, ... }:

let
  cfg = config.modules.common.shell.fzf;
in
{
  options.modules.common.shell.fzf = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable shell-fzf";
    };
  };

  config.home.packages = (with pkgs; [
    fzf
  ]);
}
