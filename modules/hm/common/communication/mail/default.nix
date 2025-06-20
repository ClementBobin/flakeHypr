{ pkgs, lib, config, ... }:

let
  cfg = config.modules.common.communication.mail;

  serviceList = cfg.services;

  # Map service names to their corresponding packages
  serviceToPackage = {
    thunderbird = pkgs.thunderbird-latest;
    bluemail    = (import ./bluemail.nix { inherit pkgs lib config; }).bluemailWithGPU;
  };

  # Get packages for enabled services, filtering out nulls
  packagesToInstall = lib.filter (pkg: pkg != null)
    (map (service: serviceToPackage.${service}) serviceList);
in
{
  options.modules.common.communication.mail = {
    services = lib.mkOption {
      type = lib.types.listOf (lib.types.enum ["thunderbird" "bluemail"]);
      default = [];
      description = "List of mail services to enable";
    };
  };

  config = {
    home.packages = packagesToInstall;
  };
}