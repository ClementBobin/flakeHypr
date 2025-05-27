{ pkgs, lib, config, ... }:

let
  cfg = config.modules.common.utilities.filezilla;
in
{
  options.modules.common.utilities.filezilla = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable filezilla";
    };
  };

  config = lib.mkIf cfg.enable {
    # Home-manager or system-wide installation based on installMethod
    home.packages = (with pkgs; [
      filezilla
    ]);
  };
}
