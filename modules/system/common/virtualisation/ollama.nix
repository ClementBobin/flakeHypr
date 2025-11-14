{ config, lib, pkgs, vars, ... }:

let
  inherit (lib) mkEnableOption mkOption types literalExpression;

  cfg = config.modules.system.virtualisation.ollama;
in {
  options.modules.system.virtualisation.ollama = {
    enable = mkEnableOption ''
      Ollama - Local LLM (Large Language Model) server
      
      Ollama allows you to run, create, and share large language models locally.
      It provides a simple API for running models like Llama, Mistral, CodeLlama,
      and other publicly available models.
      
      When enabled, this service:
      - Runs the Ollama server as a systemd service
      - Manages model storage in the specified directory
      - Provides a REST API for model interactions
      - Can be used with various clients and applications
      
      Official website: https://ollama.ai
    '';

    path = mkOption {
      type = types.str;
      default = "/var/lib/ollama";
      example = "/home/user/.ollama";
      description = ''
        Storage path for Ollama models and data.
        
        This directory will contain:
        - Downloaded model files (can be several GB each)
        - Model configurations and metadata
        - Temporary files during model operations
        
        Ensure this location has sufficient storage space for your intended models.
        Larger models like Llama2 70B may require 40+ GB of space.
      '';
    };

    settings = mkOption {
      type = types.attrsOf types.str;
      default = {};
      example = literalExpression ''
        {
          OLLAMA_NUM_PARALLEL = "2";
          OLLAMA_MAX_LOADED_MODELS = "3";
          OLLAMA_ORIGINS = "*";
        }
      '';
      description = ''
        Environment variables to configure Ollama behavior.
        
        Common configuration options:
        - OLLAMA_NUM_PARALLEL: Number of parallel model executions (default: 1)
        - OLLAMA_MAX_LOADED_MODELS: Maximum number of models to keep loaded (default: 1)
        - OLLAMA_ORIGINS: CORS origins allowed to access the API (default: "*")
        - OLLAMA_HOST: Interface to bind to (default: 127.0.0.1:11434)
        - OLLAMA_MODELS: Path to models directory (overrides the path option)
        
        See the Ollama documentation for a complete list of environment variables.
      '';
    };

    port = mkOption {
      type = types.int;
      default = 11434;
      example = 8080;
      description = ''
        TCP port for the Ollama API server.
        
        The Ollama server provides:
        - REST API endpoints at /api/~
        - Model management operations
        - Chat completions and embeddings
        - Model streaming support
        
        Change this if the default port conflicts with other services on your system.
      '';
    };

    gui.enable = mkEnableOption ''
      Next.js LLM UI - Web-based interface for Ollama
      
      A modern web interface for interacting with your local Ollama models.
      Provides a chat-based UI similar to commercial AI assistants but running
      entirely locally on your hardware.
      
      Features:
      - Chat interface with conversation history
      - Model selection and switching
      - Response streaming
      - Prompt templates
      - Multiple conversation threads
      
      GitHub: https://github.com/ollama/ollama-ui
    '';
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