{ pkgs, lib, config, ... }:

let
  cfg = config.modules.common.dev.global-tools.cli;
in
{
  options.modules.common.dev.global-tools.cli = {

    elements = lib.mkOption {
      type = lib.types.listOf (lib.types.enum ["vercel" "graphite"]);
      default = ["vercel"];
      description = "List of CLI tools to install";
    };
  };

  config = {
    home.packages = (with pkgs;
      lib.optional (lib.elem "vercel" cfg.elements) nodePackages.vercel ++
      lib.optional (lib.elem "graphite" cfg.elements) graphite-cli
    );
  };
}
