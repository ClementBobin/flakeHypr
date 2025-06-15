{
  pkgs,
  config,
  lib,
  vars,
  ...
}:

let
  cfg = config.modules.virtualisation.containers;
in
{
  options.modules.virtualisation.containers = {
    engine = lib.mkOption {
      type = lib.types.listOf (lib.types.enum ["docker" "podman"]);
      default = [];
      description = "List of container engines to enable";
    };
  };
  config = lib.mkMerge [
    (lib.mkIf (lib.elem "docker" cfg.engine) {
      users.groups.docker.members = [ "${vars.user}" ];

      virtualisation.docker.enable = true;

      environment.systemPackages = [ pkgs.docker pkgs.docker-compose ];
    })
    (lib.mkIf (lib.elem "podman" cfg.engine) {
      virtualisation.podman.enable = true;

      environment.systemPackages = [ pkgs.podman pkgs.podman-compose ];
    })
  ];
}
