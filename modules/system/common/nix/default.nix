{
  lib,
  pkgs,
  config,
  ...
}:

let
  cfg = config.modules.system.nix;
in
{
  options.modules.system.nix = {
    rebootTo = lib.mkOption {
      type = lib.types.bool;
      default = config.boot.loader.grub.enable;
      description = "Enable the 'reboot-to' script to select boot entries interactively";
    };
  };

  config = {
    environment.systemPackages = [
      (lib.mkIf cfg.rebootTo (pkgs.writeScriptBin "reboot-to" ''
        #!${pkgs.bash}/bin/bash

        if [ "$EUID" -ne 0 ]; then
          echo "Please run as root"
          exit 1
        fi

        # Get all GRUB entries
        entries=$(grep -E "menuentry ['\"].*['\"]" /boot/grub/grub.cfg | sed -E "s/menuentry ['\"](.*?)['\"].*/\1/")

        if [ "$1" = "list" ]; then
          echo "$entries" | nl
          exit 0
        fi

        # If no argument provided, use fzf to select
        if [ -z "$1" ]; then
          selected=$(echo "$entries" | ${pkgs.fzf}/bin/fzf --prompt="Select boot entry: ")
        else
          selected=$1
        fi

        if [ -n "$selected" ]; then
          grub-reboot "$selected"
          echo "System will reboot to '$selected' on next boot"
          echo "Run 'reboot' to restart now"
        else
          echo "No entry selected"
          exit 1
        fi
      ''))
    ];
  };
}
