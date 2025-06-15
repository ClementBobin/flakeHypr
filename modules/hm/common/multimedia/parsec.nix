{ pkgs, lib, config, ... }:

let
  cfg = config.modules.hm.multimedia.parsec;
in
{
  options.modules.hm.multimedia.parsec = {
    enable = lib.mkEnableOption "Enable Parsec for remote desktop access";
  };

  config = lib.mkIf cfg.enable {
    home.packages = (with pkgs; [
      parsec-bin
    ]);
  };
}
