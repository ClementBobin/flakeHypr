{ pkgs, lib, config, vars, ... }:

let
  cfg = config.modules.system.dev.languages.android;
in
{
  options.modules.system.dev.languages.android = {
    enable = lib.mkEnableOption "Android development environment";
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      android-studio
    ];

    environment.shellAliases = {
      adb-restart = "adb kill-server && adb start-server && adb devices";
    };

    programs.adb.enable = true;

    users.users.${vars.user}.extraGroups = [
      "adbusers"
      "kvm"
    ];
  };
}