{ lib, pkgs, inputs, config, ... }:

let
  cfg = config.modules.nix.polkit;
in
{
  options.modules.nix.polkit = {
    enable = lib.mkEnableOption "Enable polkit configuration";
  };

  config = lib.mkIf cfg.enable {
    # For dolphin udisks2 permission for click mounting disks
    security.polkit.extraConfig = ''
      polkit.addRule(function(action, subject) {
        if (action.id.indexOf("org.freedesktop.udisks2.") == 0 &&
            subject.isInGroup("users")) {
            return polkit.Result.YES;
        }
      });
    '';
  };
}
