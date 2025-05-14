{ pkgs, lib, config, ... }:

let
  cfg = config.modules.common.shell.tools;
in
{
  options.modules.common.shell.tools = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable shell-tools";
    };

    installMethod = lib.mkOption {
      type = lib.types.enum [ "hm" "sys" ];
      default = "hm";
      description = "Choose whether to install shell-tools via home-manager or directly in the environment.";
    };
  };

  config = lib.mkIf cfg.enable {
    # Conditional installation of tools based on the install method
    home.packages = lib.mkIf (cfg.installMethod == "hm") (with pkgs; [
      tree
    ]);
  };
}
