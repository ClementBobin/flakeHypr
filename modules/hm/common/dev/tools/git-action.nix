{ pkgs, lib, config, ... }:

let
  cfg = config.modules.hm.dev.tools.git-action;

  wrkflw = pkgs.callPackage ../../../../wrapper/wrkflw.nix {};
in
{
  options.modules.hm.dev.tools.git-action = {
    packages = lib.mkOption {
      type = lib.types.listOf (lib.types.enum ["act" "wrkflw"]);
      default = [];
      description = "The package to use for running GitHub Actions locally.";
    };
  };

  config = {
    home.packages =
      (lib.optional (lib.elem "act" cfg.packages) pkgs.act) ++
      (lib.optional (lib.elem "wrkflw" cfg.packages) wrkflw);
  };
}
