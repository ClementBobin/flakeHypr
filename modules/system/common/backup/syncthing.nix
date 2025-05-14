{
  pkgs,
  config,
  lib,
  ...
}:

let
  cfg = config.modules.backup.syncthing;
in
{
  options.modules.backup.syncthing = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable syncthing";
    };
  };

  config = lib.mkIf cfg.enable {
    services.syncthing.enable = true;
  };
}
