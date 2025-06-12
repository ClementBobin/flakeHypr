{ pkgs, lib, config, ... }:

let
  cfg = config.modules.common.dev.editor.jetbrains;
in
{
  options.modules.common.dev.editor.jetbrains = {
    enable = lib.mkEnableOption "Enable JetBrains IDEs for development";

    ides = lib.mkOption {
      type = lib.types.listOf (lib.types.enum [ "webstorm" "rider" "phpstorm" "datagrip" ]);
      default = ["webstorm" "rider" "phpstorm" "datagrip"];
      description = "List of JetBrains IDEs to install (e.g., webstorm, rider, phpstorm, datagrip)";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = lib.optionals (cfg.ides != []) (lib.concatMap (ide:
      let
        idePackage = builtins.getAttr ide pkgs.jetbrains;
      in
        [ idePackage ]
    ) cfg.ides);
  };
}
