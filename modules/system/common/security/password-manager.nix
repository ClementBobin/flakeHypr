{ config, lib, pkgs, ... }:

let
  cfg = config.modules.system.security;

  # Map password managers to their packages
  passwordManagerToPackage = with pkgs; {
    keepassxc = [ keepassxc ];
    bitwarden = [ bitwarden-desktop ];
  };

  # YubiKey packages
  yubikeyPackages = with pkgs; [
    yubikey-manager
    yubikey-personalization
    yubioath-flutter
    yubikey-touch-detector
    age
    age-plugin-yubikey
    pam_u2f
  ];

  # Get packages for enabled password managers
  passwordManagerPackages = lib.concatMap
    (manager: passwordManagerToPackage.${manager} or [])
    cfg.passwordManager.backend;

in {
  options.modules.system.security = {
    yubikey.enable = lib.mkEnableOption "Enable YubiKey support for password management";

    passwordManager = {
      backend = lib.mkOption {
        type = lib.types.listOf (lib.types.enum (builtins.attrNames passwordManagerToPackage));
        default = ["keepassxc"];
        description = "Select the password manager backend(s) to use.";
      };
    };
  };

  config = lib.mkMerge [
    (lib.mkIf cfg.yubikey.enable {
      security.pam.u2f.enable = true;
      services.pcscd.enable = true;
      services.udev.packages = with pkgs; [
        yubikey-personalization
        yubikey-manager
      ];
    })

    {
      environment.systemPackages = lib.unique (
        passwordManagerPackages
        ++ lib.optionals cfg.yubikey.enable yubikeyPackages
      );
    }
  ];
}