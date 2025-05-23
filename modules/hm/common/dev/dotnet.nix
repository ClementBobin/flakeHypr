{ pkgs, lib, config, ... }:

let
  cfg = config.modules.common.dev.dotnet;

  dotnetVersions = cfg.sdk-versions;

  dotnetPackages = map (v: pkgs."dotnet-sdk_${v}") dotnetVersions;
in
{
  options.modules.common.dev.dotnet = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable .NET development environment";
    };
    sdk-versions = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ "8" ];
      description = "List of .NET SDK versions to install (e.g. ["6" "7" "8"])";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = dotnetPackages;
  };
}
