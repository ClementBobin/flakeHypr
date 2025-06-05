{ pkgs, lib, config, ... }:

let
  cfg = config.modules.common.shell.ranger;
in
{
  options.modules.common.shell.ranger = {
    enable = lib.mkEnableOption "Enable Ranger (file manager)";
  };

  config = lib.mkIf config.modules.common.shell.ranger.enable {
    home.packages = (with pkgs; [
      ranger
    ]);
  };
}
