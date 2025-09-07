{ config, lib, pkgs, ... }:

let
  cfg = config.modules.hm.documentation.obsidian;

  #──────── Canonical default ────────#
  defaultObsiPath =
    let dflt = builtins.getEnv "XDG_DOCUMENTS_DIR";
    in if dflt == "" then "${config.home.homeDirectory}/Documents" else dflt;

  /*──────────────────────────
  │ Assets (theme & colors)  │
  └──────────────────────────*/
  obsidianDcol = pkgs.fetchurl {
    url    = "https://github.com/HyDE-Project/obsidian/raw/refs/heads/main/obsidian.dcol";
    sha256 = "sha256-yaGOGoCcPANjVT7yvtg01Odd1MFj1pkdXILTY9+PU7k=";
  };

  wallbashTheme = pkgs.fetchFromGitHub {
    owner   = "HyDE-Project";
    repo    = "obsidian";
    rev     = "main";
    sha256  = "sha256-y3OdO+jTehW87doiieW6w6FmRc+L017Zoy86Cx6tHmg=";
  };

  /*──────────────────────────
  │ Find-based TODO copier   │
  └──────────────────────────*/
  copyScript = pkgs.writeShellScript "obsidian-todo-copier" (''
    OBSIDIAN_DIR="${cfg.projectsDir}"
    DEV_DIR="${cfg.devDir}"

    # Create obsidian projects directory if it doesn't exist
    mkdir -p "$OBSIDIAN_DIR"

    rm -f "$OBSIDIAN_DIR"/*-todo.md

    # Find all TODO.md files (suppress permission errors)
    find "$DEV_DIR" -name "T[Oo][Dd][Oo].md" -type f -readable 2>/dev/null | while read -r todo_file; do
      # Get project name from path
      dir_path=$(dirname "$todo_file")
      project_name=$(basename "$dir_path")
      target_file="$OBSIDIAN_DIR/$project_name-todo.md"

      cat "$todo_file" > "$target_file"

      echo "Copied: $todo_file → $target_file"
    done
  '');
in
{
  /*──────────────────────────
  │ Module options           │
  └──────────────────────────*/
  options.modules.hm.documentation.obsidian = {
    enable = lib.mkEnableOption "Enable the Obsidian module";

    projectsDir = lib.mkOption {
      type        = lib.types.str;
      default     = "${defaultObsiPath}/obsidian/home/content/Projects";
      description = "Directory containing Obsidian project files";
    };

    devDir = lib.mkOption {
      type        = lib.types.str;
      default     = "${defaultObsiPath}/dev";
      description = "Directory containing development projects";
    };

    linker = lib.mkOption {
      type        = lib.types.bool;
      default     = true;
      description = "Enable automatic TODO.md copying at startup";
    };
  };

  /*──────────────────────────
  │ Module implementation    │
  └──────────────────────────*/
  config = lib.mkIf cfg.enable (lib.mkMerge [
    {
      home.packages = with pkgs; [
        obsidian
      ];

      home.sessionVariables.OBSIDIAN_VAULT = "${defaultObsiPath}/obsidian";

      home.file = {
        ".config/hyde/wallbash/Wall-Ways/obsidian.dcol" = {
          source   = obsidianDcol; force = true; mutable = true;
        };
        "${config.home.sessionVariables.OBSIDIAN_VAULT}/home/content/.obsidian/themes/Wallbash" = {
          source   = wallbashTheme; recursive = true; force = true; mutable = true;
        };
      };
    }

    (lib.mkIf cfg.linker {
      systemd.user.services.obsidian-todo-copier = {
        Unit = {
          Description = "Copy project TODO files to Obsidian";
          After = [ "default.target" ];
        };
        Service = {
          Type = "oneshot";
          ExecStart = "${copyScript}";
          StandardOutput = "journal";
          StandardError = "journal";
        };
        Install.WantedBy = [ "default.target" ];
      };
    })
  ]);
}