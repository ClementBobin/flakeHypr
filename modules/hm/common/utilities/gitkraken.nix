{ pkgs, lib, config, ... }:

let
  cfg = config.modules.common.utilities.gitkraken;
in
{
  options.modules.common.utilities.gitkraken = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable gitkraken development";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = (with pkgs; [
      gitkraken
    ]);
  };
}
