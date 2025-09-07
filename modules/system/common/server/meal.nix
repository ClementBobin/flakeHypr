{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.modules.system.server.meal;
in
{
  options.modules.system.server.meal = {
    clients = lib.mkOption {
      type = lib.types.listOf (lib.types.enum ["tandoor" "mealie"]);
      default = [];
      description = "List of meal clients to enable";
    };
    extraConfig = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      default = {};
      description = "Additional configuration options";
    };
  };

  config = {
    services = {
      tandoor-recipes = {
        enable = lib.elem "tandoor" cfg.clients;
        extraConfig = cfg.extraConfig;
      };

      mealie = {
        enable = lib.elem "mealie" cfg.clients;
        settings = cfg.extraConfig;
      };
    };
  };
}
