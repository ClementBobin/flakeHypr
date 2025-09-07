{ pkgs, lib, config, ... }:

let
  cfg = config.modules.hm.dev.environments;

  # Categorize different types of IDEs
  jetbrainsIDEs = with pkgs; {
    datagrip = jetbrains.datagrip;
    dataspell = jetbrains.dataspell;
    fleet = jetbrains.fleet;
    gateway = jetbrains.gateway;
    phpstorm = jetbrains.phpstorm;
    rider = jetbrains.rider;
    webstorm = jetbrains.webstorm;
  };

  otherIDEs = with pkgs; {
    android-studio = [ android-studio android-studio-tools ];
    dbeaver = dbeaver-bin;
    vs-code = null;
  };

  # Combine all IDE options
  allIDEs = jetbrainsIDEs // otherIDEs;

  # Get packages for enabled IDEs (excluding vs-code which is handled separately)
  idePackages = lib.concatMap (ide:
    let pkg = allIDEs.${ide};
    in
      if pkg == null then []
      else if lib.isList pkg then pkg
      else [ pkg ]
  ) cfg.ides;

  # Get just the JetBrains packages for remote support
  jetbrainsPackages = lib.concatMap (ide:
    if lib.hasAttr ide jetbrainsIDEs then [ jetbrainsIDEs.${ide} ] else []
  ) cfg.ides;

  hasRemoteSupport = jetbrainsPackages != [];
in
{
  options.modules.hm.dev.environments = {
    ides = lib.mkOption {
      type = lib.types.listOf (lib.types.enum (lib.attrNames allIDEs));
      default = [];
      example = [ "webstorm" "android-studio" "datagrip" "vs-code" ];
      description = "List of IDEs to install";
    };
  };

  config = {
    home.packages = idePackages;

    programs = {
      jetbrains-remote = lib.mkIf hasRemoteSupport {
        enable = true;
        ides = jetbrainsPackages;
      };

      vscode = {
        enable = lib.elem "vs-code" cfg.ides;
        package = pkgs.vscode;
      };
    };
  };
}