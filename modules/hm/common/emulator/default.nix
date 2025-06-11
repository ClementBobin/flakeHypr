{ pkgs, lib, config, ... }:

let
  cfg = config.modules.common.emulator;
in
{
  options.modules.common.emulator = {
    enable = lib.mkEnableOption "Enable emulators for running Windows applications and games on Linux";

    emulators = lib.mkOption {
      type = lib.types.listOf (lib.types.enum ["playonlinux" "proton" "wine" "bottles" "dosbox"]);
      default = ["wine"];
      description = "List of emulators to enable";
    };

    wine = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = lib.elem "wine" cfg.emulators;
        defaultText = "true if 'wine' is in emulators list";
        description = "Enable Wine Windows compatibility layer";
      };
      
      version = lib.mkOption {
        type = lib.types.enum ["stable" "staging" "wayland" "fonts"];
        default = "staging";
        description = "Wine version to install";
      };
    };

    proton = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = lib.elem "proton" cfg.emulators;
        defaultText = "true if 'proton' is in emulators list";
        description = "Enable Proton (Steam Play)";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; (
      # Wine ecosystem
      (lib.optionals (cfg.wine.enable) [
        (if cfg.wine.version == "stable" then wine else
         if cfg.wine.version == "staging" then wineStaging else
         if cfg.wine.version == "wayland" then wineWow else
         wine)
        winetricks
      ]) ++
      
      # PlayOnLinux
      (lib.optionals (lib.elem "playonlinux" cfg.emulators) [
        playonlinux
      ]) ++
      
      # Proton
      (lib.optionals (cfg.proton.enable) [
        protonup-qt
        protontricks
      ]) ++
      
      (lib.optionals (lib.elem "bottles" cfg.emulators) [
        bottles
      ]) ++
      
      # DOS emulation
      (lib.optionals (lib.elem "dosbox" cfg.emulators) [
        dosbox
      ])
    );

    # Environment variables for Wine/Proton
    home.sessionVariables = lib.mkIf (cfg.wine.enable || cfg.proton.enable) {
      WINEPREFIX = "${config.home.homeDirectory}/.wine";
      WINEARCH = "win64";
    };
  };
}