{ pkgs, lib, config, ... }:

let
  cfg = config.modules.hm.shell.tools;
in
{
  options.modules.hm.shell.tools = {
    enable = lib.mkEnableOption "Enable common shell tools";
  };

  config = lib.mkIf cfg.enable {
    # Install shell tools via home-manager
    home.packages = (with pkgs; [
      tree
    ]);
  };
}
