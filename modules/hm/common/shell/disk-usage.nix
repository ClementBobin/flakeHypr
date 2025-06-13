{ pkgs, lib, config, ... }:

let
  cfg = config.modules.common.shell.disk-usage;
  validTools = [ "ncdu" "diskonaut" "gdu" "dust" "parallel-disk-usage" "squirreldisk" ];
in
{
  options.modules.common.shell.disk-usage = {
    tools = lib.mkOption {
      type = lib.types.listOf (lib.types.enum validTools);
      default = [];
      description = "List of disk usage analyzers to install.";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = builtins.map (tool: pkgs.${tool}) cfg.tools;
  };
}