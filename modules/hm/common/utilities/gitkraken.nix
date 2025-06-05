{ pkgs, lib, config, ... }:

let
  cfg = config.modules.common.utilities.gitkraken;
in
{
  options.modules.common.utilities.gitkraken = {
    enable = lib.mkEnableOption "Enable GitKraken (Git GUI client)";
  };

  config = lib.mkIf cfg.enable {
    home.packages = (with pkgs; [
      gitkraken
    ]);
  };
}
