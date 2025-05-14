{
  pkgs,
  config,
  lib,
  vars,
  ...
}:

let
  cfg = config.modules.virtualisation.docker;
in
{
  options.modules.virtualisation.docker = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable docker";
    };
  };

  config = lib.mkIf cfg.enable {
    users.groups.docker.members = [ "${vars.user}" ];

    virtualisation.docker.enable = true;

    environment.systemPackages = [ pkgs.docker pkgs.docker-compose ];
  };
}
