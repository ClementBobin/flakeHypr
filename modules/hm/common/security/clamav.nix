{ pkgs, lib, config, ... }:

let
  cfg = config.modules.common.security.clamav;
in
{
  options.modules.common.security.clamav = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable ClamAV antivirus tools.";
    };

    gui = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable ClamTK GUI for ClamAV.";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      clamav
    ] ++ lib.optionals cfg.gui.enable [
      clamtk
    ];
  };
}
