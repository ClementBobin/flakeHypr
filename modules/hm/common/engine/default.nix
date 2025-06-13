{ pkgs, lib, config, vars, ... }:

let
  cfg = config.modules.common;
in
{
  options.modules.common = {
    engine = lib.mkOption {
      type = lib.types.listOf (lib.types.enum ["unity"]);
      default = [];
      description = "List of game engines to install";
    };
  };

  config = {
    home.packages = with pkgs; (
      (lib.optionals (lib.elem "unity" cfg.engine) [unityhub])
    );
  };
}
