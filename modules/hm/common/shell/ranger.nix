{ pkgs, lib, config, ... }:

let
  cfg = config.modules.common.shell.ranger;
in
{
  options.modules.common.shell.ranger = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable shell-ranger";
    };

    installMethod = lib.mkOption {
      type = lib.types.enum [ "hm" "sys" ];
      default = "hm";
      description = "Choose how to install shell-ranger.";
    };
  };

  config = lib.mkIf config.modules.common.shell.ranger.enable {
    home.packages = lib.mkIf (cfg.installMethod == "hm") (with pkgs; [
      ranger
    ]);
  };
}
