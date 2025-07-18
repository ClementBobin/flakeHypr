{ pkgs, lib, config, ... }:

let
  cfg = config.modules.hm.communication.mail;

  serviceList = cfg.services;

  # Map service names to their corresponding packages or list of packages
  serviceToPackage = {
    thunderbird = [ pkgs.thunderbird-latest ];
    bluemail    = [ (import ./bluemail.nix { inherit pkgs lib config; }).bluemailWithGPU ];
  };

  # Flatten the list of packages from all enabled services
  packagesToInstall = lib.unique (lib.concatMap (s: serviceToPackage.${s}) serviceList);
in
{
  options.modules.hm.communication.mail = {
    services = lib.mkOption {
      type = lib.types.listOf (lib.types.enum (lib.attrNames serviceToPackage));
      default = [];
      description = "List of mail services to enable";
    };
  };

  config = {
    home.packages = packagesToInstall;
  };
}