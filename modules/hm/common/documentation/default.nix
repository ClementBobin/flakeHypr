{ pkgs, lib, config, ... }:

let
  cfg = config.modules.hm.documentation;

  # Map document editors to their packages
  editorsToPackage = with pkgs; {
    onlyoffice = null;
  };

  # Get packages for enabled editors
  editorsPackages = lib.unique (lib.filter (pkg: pkg != null)
    (map (e: editorsToPackage.${e} or null) cfg.editors));

in
{
  options.modules.hm.documentation = {
    editors = lib.mkOption {
      type = lib.types.listOf (lib.types.enum (lib.attrNames editorsToPackage));
      default = [];
      example = [ "onlyoffice" ];
      description = "List of document editors to install";
    };
  };

  config = {
    programs.onlyoffice.enable = lib.elem "onlyoffice" cfg.editors;
  };
}