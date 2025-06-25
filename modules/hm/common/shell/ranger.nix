{ pkgs, lib, config, ... }:

let
  cfg = config.modules.hm.shell.ranger;
in
{
  options.modules.hm.shell.ranger = {
    enable = lib.mkEnableOption "Enable Ranger (file manager)";
  };

  config = lib.mkIf cfg.enable {
    home.packages = (with pkgs; [
      ranger
    ]);
  };
}
