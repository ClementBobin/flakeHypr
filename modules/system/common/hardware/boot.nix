{
  pkgs,
  config,
  lib,
  ...
}:

let
  cfg = config.modules.system.hardware.boot;
in
{

  options.modules.system.hardware.boot = {
    enable = lib.mkEnableOption "Enable boot configuration for Hydenix systems";
  };

  config = lib.mkIf cfg.enable {
    hydenix.boot.enable = false;

    boot = {
      plymouth.enable = true;
      kernelPackages = pkgs.linuxPackages_zen;
      loader.systemd-boot.enable = pkgs.lib.mkForce false;
      loader = {
        efi = {
          canTouchEfiVariables = true;
        };
        grub = {
          enable = true;
          device = "nodev";
          useOSProber = true;
          efiSupport = true;
          # theme = pkgs.hydenix.grub-retroboot;
          extraEntries = ''
            menuentry "UEFI Firmware Settings" {
              fwsetup
            }
          '';
        };
      };
      kernelModules = [
        "v4l2loopback"
      ];
      extraModprobeConfig = ''
        options v4l2loopback devices=2 video_nr=1,2 card_label="OBS Cam, Virt Cam" exclusive_caps=1
      '';
    };

    environment.systemPackages = with pkgs; [
      efibootmgr
      os-prober
    ];
  };
}
