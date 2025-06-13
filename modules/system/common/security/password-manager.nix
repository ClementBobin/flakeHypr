{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.modules.security;
in {
  options.modules.security = {
    yubikey.enable = mkEnableOption "Enable YubiKey support for password management";

    passwordManager = {
      backend = mkOption {
        type = types.listOf (types.enum ["keepassxc" "bitwarden"]);
        default = ["keepassxc"];
        description = "Select the password manager backend(s) to use.";
      };
    };
  };

  config = {
    services.pcscd.enable = cfg.yubikey.enable;

    services.udev.packages = lib.optionals cfg.yubikey.enable [
      pkgs.yubikey-personalization
    ];

    environment.systemPackages =
      (lib.optionals cfg.yubikey.enable [
        pkgs.yubikey-manager
        pkgs.yubikey-personalization
        pkgs.yubioath-flutter
        pkgs.yubikey-touch-detector
        pkgs.age
        pkgs.age-plugin-yubikey
        pkgs.pam_u2f
      ]) ++
      (lib.optionals (lib.elem "keepassxc" cfg.passwordManager.backend) [
        pkgs.keepassxc
      ]) ++
      (lib.optionals (lib.elem "bitwarden" cfg.passwordManager.backend) [
        pkgs.bitwarden
      ]);
  };
}