{
  config,
  lib,
  ...
}:

let
  cfg = config.modules.system.hardware.autologin;
in
{
  options.modules.system.hardware.autologin = {
    enable = lib.mkEnableOption "Enable autologin for SDDM";

    user = lib.mkOption {
      type = lib.types.str;
      description = "User to autologin";
    };

    session = lib.mkOption {
      type = lib.types.str;
      description = "Session to autologin";
    };
  };
  config = lib.mkIf cfg.enable {
    services = {
      displayManager = {
        sddm = {
          enable = true;
          wayland.enable = true;
          settings = {
            Autologin = {
              Session = "${cfg.session}.desktop";
              User = cfg.user;
            };
          };
        };
        defaultSession = "${cfg.session}.desktop";
      };
    };
  };
}
