{ pkgs, lib, config, ... }:

let
  cfg = config.modules.common.security.stacer;
in
{
  options.modules.common.security.stacer = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable stacer.";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = (with pkgs; [
      stacer
    ]);
  };
}
