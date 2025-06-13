{ pkgs, lib, config, ... }:

let
  cfg = config.modules.common.documentation;
in
{
  options.modules.common.documentation = {
    enable = lib.mkEnableOption "Enable document editor";

    editor = lib.mkOption {
      type = lib.types.listOf (lib.types.enum ["onlyoffice"]);
      default = [];
      description = "List of document editors to install";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = (with pkgs; [
      (lib.optionals (lib.elem "onlyoffice" cfg.editor) onlyoffice-bin)
    ]);
  };
}
