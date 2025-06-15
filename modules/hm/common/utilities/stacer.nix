{ pkgs, lib, config, ... }:

let
  cfg = config.modules.hm.utilities.stacer;
in
{
  options.modules.hm.utilities.stacer = {
    enable = lib.mkEnableOption "Enable Stacer system optimizer and monitoring tool";
  };

  config = lib.mkIf cfg.enable {
    home.packages = (with pkgs; [
      stacer
    ]);
  };
}
