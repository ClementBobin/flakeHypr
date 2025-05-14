{ pkgs, lib, config, ... }:

let
  cfg = config.modules.common.multimedia.openshot-qt;
in
{
  options.modules.common.multimedia.openshot-qt = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable openshot-qt";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = (with pkgs; [
      openshot-qt
    ]);
  };
}
