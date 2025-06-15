{
  pkgs,
  lib,
  config,
  vars,
  ...
}:
let
  cfg = config.modules.hm.shell.starship;
in
{
  options.modules.hm.shell.starship = {
    enable = lib.mkEnableOption "Enable Starship (cross-shell prompt)";
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
