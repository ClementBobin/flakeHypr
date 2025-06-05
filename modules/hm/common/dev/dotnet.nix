{ pkgs, lib, config, ... }:

let
  cfg = config.modules.common.dev.dotnet;

  sdkVersions = cfg.sdk-versions;

  dotnetPackages = (map (v: pkgs."dotnet-sdk_${v}") sdkVersions) ++
    (map (pkgName:
      if pkgs ? ${pkgName}
      then pkgs.${pkgName}
      else throw "Package '${pkgName}' not found in pkgs"
    ) cfg.extraPackages);

in
{
  options.modules.common.dev.dotnet = {
    enable = lib.mkEnableOption "Enable .NET development environment";
    sdk-versions = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ "8" ];
      description = "List of .NET SDK versions to install (e.g. ["6" "7" "8"])";
    };
    extraPackages = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
      description = "Additional .NET packages to install; need to specify dotnetPackages.{name of package  (e.g. ['nuget' 'dotnet-ef'])}";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = dotnetPackages;
  };
}
