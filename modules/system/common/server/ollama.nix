{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.modules.system.server.ollama;
in
{
  options.modules.system.server.ollama = {
    enable = lib.mkEnableOption "Enable Ollama server";

    models = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [];
        description = "List of Ollama models to enable";
    };

    acceleration = lib.mkOption {
        type = lib.types.enum [null "rocm" "cuda" "vulkan"];
        default = null;
        description = "Acceleration type for Ollama server";
    };

    sync = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable model synchronization for Ollama server";
    }
  };

  config = {
    services = {
        ollama = {
            enable = cfg.enable
            loadModels = cfg.models
            acceleration = cfg.acceleration;
            syncModels = cfg.sync
        };
    };
  };
}
