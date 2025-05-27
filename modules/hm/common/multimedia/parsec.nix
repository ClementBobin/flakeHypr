{ pkgs, lib, config, ... }:

let
  cfg = config.modules.common.multimedia.parsec;
in
{
  options.modules.common.multimedia.parsec = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable parsec";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = (with pkgs; [
      parsec-bin
    ]);
  };
}
