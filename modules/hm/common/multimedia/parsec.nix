{ pkgs, lib, config, ... }:

let
  cfg = config.modules.common.multimedia.parsec;
in
{
  options.modules.common.multimedia.parsec = {
    enable = lib.mkEnableOption "Enable Parsec for remote desktop access";
  };

  config = lib.mkIf cfg.enable {
    home.packages = (with pkgs; [
      parsec-bin
    ]);
  };
}
