{ pkgs, lib, config, ... }:

let
  cfg = config.modules.common.utilities.stacer;
in
{
  options.modules.common.utilities.stacer = {
    enable = lib.mkEnableOption "Enable Stacer system optimizer and monitoring tool";
  };

  config = lib.mkIf cfg.enable {
    home.packages = (with pkgs; [
      stacer
    ]);
  };
}
