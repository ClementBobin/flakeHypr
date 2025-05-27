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
  };

  config = lib.mkIf cfg.enable {
    home.packages = (with pkgs; [
      userPkgs.jetbrains.webstorm
      #userPkgs.jetbrains.gateway
      #userPkgs.jetbrains-toolbox
      userPkgs.jetbrains.rider
      userPkgs.jetbrains.phpstorm
      userPkgs.jetbrains.datagrip
    ]);
  };
}
