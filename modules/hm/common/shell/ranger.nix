{ pkgs, lib, config, ... }:

let
  cfg = config.modules.common.shell.ranger;
in
{
  options.modules.common.shell.ranger = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable shell-ranger";
    };
  };

  config = lib.mkIf config.modules.common.shell.ranger.enable {
    home.packages = (with pkgs; [
      ranger
    ]);
  };
}
