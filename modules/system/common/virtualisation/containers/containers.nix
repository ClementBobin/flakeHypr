{
  pkgs,
  config,
  lib,
  vars,
  ...
}:

let
  cfg = config.modules.virtualisation;
in
{
  options.modules.virtualisation = {
    docker = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable docker";
      };
    };
    podman = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable podman";
      };
    };
  };
  config = lib.mkMerge [
    (lib.mkIf cfg.docker.enable {
      users.groups.docker.members = [ "${vars.user}" ];

      virtualisation.docker.enable = true;

      environment.systemPackages = [ pkgs.docker pkgs.docker-compose ];
    })
    (lib.mkIf cfg.podman.enable {
      virtualisation.podman.enable = true;

      environment.systemPackages = [ pkgs.podman pkgs.podman-compose ];
    })
  ];
}
