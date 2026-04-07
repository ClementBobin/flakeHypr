{ pkgs, lib, config, ... }:
let
  cfg = config.modules.hm.utilities.app-launcher;
  clientsToPackage = with pkgs; {
    hyprshell = [ hyprshell ];
  };
  clientsPackages = lib.concatMap (client: clientsToPackage.${client} or []) cfg.clients;
in {
  options.modules.hm.utilities.app-launcher = {
    clients = lib.mkOption {
      type = lib.types.listOf (lib.types.enum (lib.attrNames clientsToPackage));
      default = [];
      description = "List of application launchers to enable";
    };
  };

  config = {
    home.packages = clientsPackages;

    systemd.user.services.hyprshell = lib.mkIf (builtins.elem "hyprshell" cfg.clients) {
      Unit = {
        Description = "Hyprshell application launcher daemon";
        After = [ "hyprland-session.target" ];
        PartOf = [ "hyprland-session.target" ];
      };
      Service = {
        ExecStart = "${pkgs.hyprshell}/bin/hyprshell run";
        Restart = "on-failure";
      };
      Install = {
        WantedBy = [ "hyprland-session.target" ];
      };
    };
  };
}