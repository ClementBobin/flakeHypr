{ pkgs, lib, config, ... }:

let
  cfg = config.modules.common.dev.editor.jetbrains;
in
{
  options.modules.common.dev.editor.jetbrains = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable jetbrains development";
    };

    installMethod = lib.mkOption {
      type = lib.types.enum [ "hm" "sys" ];
      default = "hm";
      description = "Choose whether to install jetbrains tools via home-manager or directly in the environment.";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = lib.mkIf (cfg.installMethod == "hm") (with pkgs; [
      userPkgs.jetbrains.webstorm
      #userPkgs.jetbrains.gateway
      #userPkgs.jetbrains-toolbox
      userPkgs.jetbrains.rider
      userPkgs.jetbrains.phpstorm
      userPkgs.jetbrains.datagrip
    ]);
  };
}
