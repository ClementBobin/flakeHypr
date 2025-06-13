{ pkgs, lib, config, ... }:

let
  cfg = config.modules.common.documentation;
in
{
  options.modules.common.documentation = {
    editor = lib.mkOption {
      type = lib.types.listOf (lib.types.enum ["onlyoffice" "okular"]);
      default = [];
      description = "List of document editors to install";
    };
  };

  config = {
    home.packages = with pkgs; (
      (lib.optional (lib.elem "onlyoffice" cfg.editor) onlyoffice-bin) ++
      (lib.optional (lib.elem "okular" cfg.editor) okular)
    );
  };
}
