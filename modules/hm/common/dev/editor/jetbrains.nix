{ pkgs, lib, config, ... }:

let
  cfg = config.modules.common.dev.editor.jetbrains;
in
{
  options.modules.common.dev.editor.jetbrains = {
    enable = lib.mkEnableOption "Enable JetBrains IDEs for development";
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
