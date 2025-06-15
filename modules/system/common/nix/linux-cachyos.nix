{
  lib,
  pkgs,
  inputs,
  config,
  ...
}:

let
  cfg = config.modules.system.nix.linux-cachyos;
in
{
  imports = [ inputs.chaotic.nixosModules.default ];
  options.modules.system.nix.linux-cachyos = {
    enable = lib.mkEnableOption "Enable Chaotic-AUR (CachyOS) support";
    enableSCX = lib.mkEnableOption "Enable SCX service when using Chaotic-AUR (CachyOS)";
  };

  config = lib.mkIf cfg.enable {

    boot.kernelPackages = lib.mkForce pkgs.linuxPackages_cachyos;

    nix.settings = {
      substituters = [
        "https://chaotic-nyx.cachix.org"
      ];
      trusted-public-keys = [
        "chaotic-nyx.cachix.org-1:HfnXSw4pj95iI/n17rIDy40agHj12WfF+Gqk6SonIT8="
      ];
    };

    services.scx.enable = cfg.enableSCX;
  };
}
