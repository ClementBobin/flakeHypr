{ pkgs, lib, config, ... }:

let
  cfg = config.modules.hm.emulator;

  # Map emulators to their packages
  emulatorToPackage = with pkgs; {
    playonlinux = [ playonlinux ];
    bottles = [ bottles ];
    dosbox = [ dosbox ];
  };

  # Wine packages based on version
  winePackages = with pkgs; {
    stable = wine;
    wayland = wineWayland;
    fonts = wine;
  };

  # Proton packages
  protonPackages = with pkgs; [
    protonup-qt
    protontricks
  ];

  # Get packages for enabled emulators
  baseEmulatorPackages = lib.concatMap (emulator: emulatorToPackage.${emulator} or []) cfg.emulators;

  # Additional packages based on configuration
  additionalPackages = with pkgs; []
    ++ lib.optionals cfg.wine.enable [ (winePackages.${cfg.wine.version} or pkgs.wine) winetricks ]
    ++ lib.optionals cfg.proton.enable protonPackages;

in {
  options.modules.hm.emulator = {
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
        type = lib.types.enum ["stable" "wayland" "fonts"];
        default = "stable";
        description = "Wine version to install";
      };

      prefix = lib.mkOption {
        type = lib.types.str;
        default = "${config.home.homeDirectory}/.wine";
        description = "Custom WINEPREFIX value";
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

  config = {
    home.packages = lib.unique (baseEmulatorPackages ++ additionalPackages);

    # Environment variables for Wine/Proton
    home.sessionVariables = lib.mkIf (cfg.wine.enable || cfg.proton.enable) {
      WINEPREFIX = cfg.wine.prefix;
      WINEARCH = "win64";
    };
  };
}