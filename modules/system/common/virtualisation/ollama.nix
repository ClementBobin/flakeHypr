{ config, lib, pkgs, vars, ... }:

let
  inherit (lib) mkEnableOption mkOption types;

  cfg = config.modules.system.virtualisation.ollama;
in {
  options.modules.system.virtualisation.ollama = {
    enable = mkEnableOption "Enable Ollama (AI model server)";
    path = mkOption {
      type = types.str;
      default = "/var/lib/ollama";
      description = "Path to Ollama data directory";
    };
    settings = mkOption {
      type = types.attrsOf types.str;
      default = {};
      description = "Additional environment variables for Ollama service";
    };
    port = mkOption {
      type = types.int;
      default = 11434;
      description = "Port for Ollama service";
    };

    gui.enable = mkEnableOption "Enable Ollama LLM UI (Next.js frontend)";
  };

  config = {
    services = {
      ollama = {
        enable = cfg.enable;
        home = cfg.path;
        environmentVariables = cfg.settings;
        port = cfg.port;
      };
      nextjs-ollama-llm-ui = {
        enable = cfg.gui.enable;
        ollamaUrl = "http://127.0.0.1:${toString cfg.port}";
      };
    };
  };
}