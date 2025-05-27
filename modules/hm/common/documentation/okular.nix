{ pkgs, lib, config, ... }:

let
  cfg = config.modules.common.documentation.okular;
in
{
  options.modules.common.documentation.okular = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable okular";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = (with pkgs; [
      okular
    ]);
  };
}
