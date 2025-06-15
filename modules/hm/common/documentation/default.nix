{ pkgs, lib, config, ... }:

let
  cfg = config.modules.hm.documentation;

  # Map document editors to their packages
  editorToPackage = with pkgs; {
    onlyoffice = onlyoffice-bin;
    okular = okular;
  };

  # Get packages for enabled editors
  editorPackages = lib.filter (pkg: pkg != null)
    (map (editor: editorToPackage.${editor} or null) cfg.editor);

in
{
  options.modules.hm.documentation = {
    editor = lib.mkOption {
      type = lib.types.listOf (lib.types.enum ["onlyoffice" "okular"]);
      default = [];
      description = "List of document editors to install";
    };
  };

  config = {
    home.packages = editorPackages;
  };
}