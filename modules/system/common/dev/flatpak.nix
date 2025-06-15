{
  pkgs,
  config,
  lib,
  ...
}:

let
  cfg = config.modules.system.dev.flatpak;
in
{
  options.modules.system.dev.flatpak = {
    enable = lib.mkEnableOption "Enable Flatpak development environment";

    flathubRepoUrls = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ "https://flathub.org/repo/flathub.flatpakrepo" ];
      description = "List of URLs of Flathub repositories to add for Flatpak applications.";
    };

    deployTool.enable = lib.mkEnableOption "Enable Flatpak deploy tool";
  };

  config = lib.mkIf cfg.enable {
    services.flatpak.enable = true;
    systemd.services.flatpak-repo = {
      wantedBy = [ "multi-user.target" ];
      path = [ pkgs.flatpak ];
      script = ''
        ${lib.concatStringsSep "\n" (lib.imap0 (i: url: ''
          flatpak remote-add --if-not-exists flathub-repo-${toString i} ${url}
        '') cfg.flathubRepoUrls)}
      '';
    };

    environment.systemPackages = lib.mkIf cfg.deployTool.enable (with pkgs; [
      flatpak-builder
    ]);
  };
}
