{ pkgs-unstable, lib, config, ... }:
let
  cfg = config.modules.hm.dev.tools.opencode;
in
{
  options.modules.hm.dev.tools.opencode = {
    enable = lib.mkEnableOption "Enable opencode tool";
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs-unstable; [
      opencode
      opencode-desktop
    ];
  };
}