{ pkgs, lib, config, vars, ... }:

let
  cfg = config.modules.common.engine.unity;
in
{
  options.modules.common.engine.unity = {
    enable = lib.mkEnableOption "Enable Unity Hub for managing Unity installations";
  };

  config = lib.mkIf cfg.enable {
    home.packages = (with pkgs; [
      unityhub
    ]);
  };
}
