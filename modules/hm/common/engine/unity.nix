{ pkgs, lib, config, vars, ... }:

let
  cfg = config.modules.common.engine.unity;
in
{
  options.modules.common.engine.unity = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable unity support.";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = (with pkgs; [
      unityhub
    ]);
  };
}
