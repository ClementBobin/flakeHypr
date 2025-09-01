{ pkgs, lib, config, ... }:

let
  cfg = config.modules.hm.utilities.app-launcher.kando;

  themeRepo = {
    owner = "kando-menu";
    repo = "menu-themes";
    tag = "v0.2.0";
  };

  officialThemes = {
    "EVNTech Vache" = {
      file = "evntech-vache.zip";
      sha256 = "sha256-TjpoWjofftAwbYOtOCxyYZT0nycfnvJ54jbGOyaKGbk=";
    };
    "Hexperiment" = {
      file = "hexperiment.zip";
      sha256 = "sha256-Ea3mReYlveh+fLpslSn1M35K2gTjkGHojh+6vdL1//g=";
    };
    "KnightForge" = {
      file = "knight-forge.zip";
      sha256 = "sha256-MVpO1gAnir7RGHfLfaCtNLJ+b1ZAAMjIJeU0fJiB9os=";
    };
    "Minecraft" = {
      file = "minecraft.zip";
      sha256 = "sha256-plZ7mVVhh1l1USDmmWmtq4N9M9fhz/jbl1hqmtmafRY=";
    };
    "Modified Bent Photon" = {
      file = "modified-bent-photon.zip";
      sha256 = "sha256-xSv3HIO+QaKbmknFXi4QTAeHG6I0OJKgFf0PwVFxWMM=";
    };
    "Neo Ring" = {
      file = "neo-ring.zip";
      sha256 = "sha256-+45ptjzsjSyDIo0WWnZUfN4c6UeG1AV7qDrrCRDro7g=";
    };
    "Neon Lights Color" = {
      file = "neon-lights-color.zip";
      sha256 = "sha256-5QOJQroqa/lpjKYcP50GXVs7WTToz9BUrbkDHxjiQqw=";
    };
    "Nether Labels" = {
      file = "nether-labels.zip";
      sha256 = "sha256-rlb/s8R0MpaOv/BHV5s2RasVOAyenldT9LDxi+COqxs=";
    };
    "Nord" = {
      file = "nord.zip";
      sha256 = "sha256-Zx9Dxwo68soPjinUEZB3WGF3oYwh6mDJ5PL7Am1u+BM=";
    };
  };

  fetchOfficialTheme = name:
    let
      theme = officialThemes.${name};
      src = pkgs.fetchzip {
        url = "https://github.com/${themeRepo.owner}/${themeRepo.repo}/releases/download/${themeRepo.tag}/${theme.file}";
        sha256 = theme.sha256;
        stripRoot = false;
      };
      themeDir = "${src}/${lib.removeSuffix ".zip" theme.file}";
    in
    pkgs.runCommand "kando-theme-${name}" {} ''
      mkdir -p $out
      
      if [ ! -d "${themeDir}" ]; then
        echo "Error: Theme directory not found: ${themeDir}"
        echo "Contents of extracted zip:"
        ls -la "${src}"
        exit 1
      fi
      
      cp -r "${themeDir}"/* $out/
      
      if [ ! -f "$out/theme.json5" ]; then
        echo "Error: Required file theme.json5 missing in theme"
        ls -la $out
        exit 1
      fi
    '';

  installThemes = themes:
    lib.listToAttrs (map (name:
      lib.nameValuePair ".config/kando/menu-themes/${name}" {
        source = fetchOfficialTheme name;
        recursive = true;
      }
    ) themes);

in {
  options.modules.hm.utilities.app-launcher.kando = {
    enable = lib.mkEnableOption "Kando application launcher";

    menuThemes = lib.mkOption {
      type = with lib.types; listOf (enum (lib.attrNames officialThemes));
      default = [];
      description = ''
        List of official menu themes to install.
        Available themes: ${toString (lib.attrNames officialThemes)}
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs.kando ];
    home.file = installThemes cfg.menuThemes;
  };
}