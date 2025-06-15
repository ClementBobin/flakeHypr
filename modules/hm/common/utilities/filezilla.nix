{ pkgs, lib, config, ... }:

let
  cfg = config.modules.hm.utilities.filezilla;
in
{
  options.modules.hm.utilities.filezilla = {
    enable = lib.mkEnableOption "Enable FileZilla (FTP client)";
  };

  config = lib.mkIf cfg.enable {
    # Install shell tools via home-manager
    home.packages = (with pkgs; [
      filezilla
    ]);
  };
}
