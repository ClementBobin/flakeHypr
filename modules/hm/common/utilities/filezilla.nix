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

    installMethod = lib.mkOption {
      type = lib.types.enum [ "hm" "sys" ];
      default = "hm";
      description = "Choose whether to install filezilla via home-manager or directly in the environment.";
    };
  };

  config = lib.mkIf cfg.enable {
    # Home-manager or system-wide installation based on installMethod
    home.packages = lib.mkIf (cfg.installMethod == "hm") (with pkgs; [
      filezilla
    ]);
  };
}
