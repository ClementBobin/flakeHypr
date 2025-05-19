{ pkgs, lib, config, ... }:

let
  cfg = config.modules.common.communication.mail.thunderbird;
in
{
  options.modules.common.communication.mail.thunderbird = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable thunderbird";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = (with pkgs; [
      thunderbird-latest
    ]);
  };
}
