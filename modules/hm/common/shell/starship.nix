{
  pkgs,
  lib,
  config,
  vars,
  ...
}:
let
  cfg = config.modules.common.shell.starship;
in
{
  options.modules.common.shell.starship = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable starship.";
    };
  };

  config = lib.mkIf cfg.enable {

    # Install starship if desired
    # Configure starship prompt for various shells
    programs.starship = {
      # Enable starship
      enable = true;
    };
  };
}
