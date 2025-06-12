{ pkgs, lib, config, ... }:

let
  cfg = config.modules.common.shell.tools;
in
{
  options.modules.common.shell.tools = {
    enable = lib.mkEnableOption "Enable common shell tools";
  };

  config = lib.mkIf cfg.enable {
    # Install shell tools via home-manager
    home.packages = (with pkgs; [
      tree
    ]);
  };
}
