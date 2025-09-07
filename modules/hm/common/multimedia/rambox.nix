{ pkgs, config, lib, ... }:

let
  cfg = config.modules.hm.multimedia.rambox;
in
{
  options.modules.hm.multimedia.rambox = {
    enable = lib.mkEnableOption "Enable Rambox for Workspace Simplifier - a cross-platform application organizing web services into Workspaces similar to browser profiles";
  };

  config = lib.mkIf cfg.enable {
    home.packages = (with pkgs; [
      rambox
    ]);
  };
}
