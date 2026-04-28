{ pkgs, lib, config, ... }:

let
  cfg = config.modules.hm.dev.tools.claude;
in
{
  options.modules.hm.dev.tools.claude = {
    enable = lib.mkEnableOption "Enable Claude tool";
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
        claude-code
        claude-monitor
        claude-code-acp
    ];
  };
}
