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
  │ Git‑based backup script  │
  └──────────────────────────*/
  backupScript = pkgs.writeShellScript "obsidian-backup-git" ''
    set -euo pipefail

    REG_FILE="''${XDG_CONFIG_HOME:-$HOME/.config}/obsidian/obsidian.json"
    if [ ! -f "$REG_FILE" ]; then
      echo "No vault registry found at $REG_FILE — nothing to back up."
      exit 0
    fi

    mapfile -t vaults < <(${pkgs.jq}/bin/jq -r '.[].path' "$REG_FILE" | ${pkgs.gawk}/bin/awk '!seen[$0]++')
    if [ ''${#vaults[@]} -eq 0 ]; then
      echo "Vault registry is empty."
      exit 0
    fi

    for VAULT in "''${vaults[@]}"; do
      if [ ! -d "$VAULT" ]; then
        echo "⚠️  $VAULT missing — skipping"
        continue
      fi
      gitDir="$(find "$VAULT" -maxdepth 2 -type d -name .git | head -n1 || true)"
      if [ -z "$gitDir" ]; then
        echo "ℹ️  $VAULT is not a git repo — skipping"
        continue
      fi

      cd "$VAULT"
      echo "→ Backing up: $VAULT"
      git fetch --quiet origin || true
      if git show-ref --verify --quiet refs/heads/temp; then
        git checkout temp
      else
        git checkout -B temp
      fi
      git add -A
      git commit -m "Backup on $(date -u +"%Y-%m-%dT%H:%M:%SZ")" || echo "  Nothing new to commit"
      if ! git push origin temp; then
        echo "⚠️  Failed to push $VAULT to remote"
        continue
      fi
    done
  '';

  /*──────────────────────────
  │ TODO‑link monitoring     │
  └──────────────────────────*/
  linkScript = pkgs.writeShellScript "obsidian-todo-linker" ''
    OBSIDIAN_DIR="${cfg.projectsDir}"
    DEV_DIR="${cfg.devDir}"

    # Create obsidian projects directory if it doesn't exist
    mkdir -p "$OBSIDIAN_DIR"
    mkdir -p "$DEV_DIR"

    # Variable to track last update time
    last_update=0
    update_interval=1  # Minimum seconds between updates

    # Function to create/update hardlinks
    update_links() {
      current_time=$(date +%s)
      time_diff=$((current_time - last_update))

      # Only update if enough time has passed since last update
      if [ $time_diff -ge $update_interval ]; then
        find "$DEV_DIR" -maxdepth "${toString cfg.searchLinkerDepth}" -name "TODO.md" | while read -r todo_file; do
          project_name=$(basename "$(dirname "$todo_file")")
          target_link="$OBSIDIAN_DIR/$project_name-todo.md"

          # Remove existing link if it exists
          rm -f "$target_link"
          # Create new hardlink
          ln "$todo_file" "$target_link"
        done
        last_update=$current_time
      fi
    }

    # Initial link creation
    update_links

    # Monitor both directories for changes
    ${pkgs.inotify-tools}/bin/inotifywait -m -r -e modify,create,delete,move "$DEV_DIR" "$OBSIDIAN_DIR" | while read -r directory events filename; do
      if [[ "$filename" == "TODO.md" ]] || [[ "$filename" == *-todo.md ]]; then
        update_links
      fi
    done
  '';
in
{
  /*──────────────────────────
  │ Module options           │
  └──────────────────────────*/
  options.modules.hm.documentation.obsidian = {
    enable = lib.mkEnableOption "Enable the Obsidian module";

    backupMethod = lib.mkOption {
      type    = lib.types.enum [ "none" "git-push-temp" ];
      default = "none";
      description = ''
        Backup strategy.
        • none – disable backups
        • git-push-temp – commit & push vault to the **temp** branch
      '';
    };

    projectsDir = lib.mkOption {
      type        = lib.types.str;
      default     = "${defaultObsiPath}/obsidian/home/Projects";
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
      description = "Create hard‑links from each project’s TODO.md into the vault";
    };

    searchLinkerDepth = lib.mkOption {       # ← renamed for consistency
      type        = lib.types.int;
      default     = 2;
      description = "Max depth to search for TODO.md files under devDir";
    };
  };

  /*──────────────────────────
  │ Module implementation    │
  └──────────────────────────*/
  config = lib.mkIf cfg.enable {

    home.packages = with pkgs; [ obsidian inotify-tools jq gawk ];

    home.sessionVariables.OBSIDIAN_VAULT = "${defaultObsiPath}/obsidian";

    home.file = {
      ".config/hyde/wallbash/Wall-Ways/obsidian.dcol" = {
        source   = obsidianDcol; force = true; mutable = true;
      };
      "${config.home.sessionVariables.OBSIDIAN_VAULT}/home/.obsidian/themes/Wallbash" = {
        source   = wallbashTheme; recursive = true; force = true; mutable = true;
      };
    };

    home.activation.obsidianBackup = lib.mkIf (cfg.backupMethod == "git-push-temp") (
      lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        echo "Running Obsidian backup to temp branch…"
        ${backupScript}
      ''
    );

    systemd.user = lib.mkIf (cfg.backupMethod == "git-push-temp") {
      services.obsidian-backup = {
        Unit.Description = "Obsidian vault backup to git temp branch";
        Service = { Type = "oneshot"; ExecStart = "${backupScript}"; StandardOutput = "journal"; StandardError = "journal"; };
      };
      timers.obsidian-backup = {
        Unit.Description = "Run Obsidian vault backup every 7 days";
        Timer = {
          OnBootSec       = "5m";
          OnUnitActiveSec = "7d";
          Persistent      = true;
          Unit            = "obsidian-backup.service";
        };
        Install.WantedBy = [ "timers.target" ];
      };

      services.obsidian-todo-linker = lib.mkIf cfg.linker {
        Unit.Description = "Link & monitor project TODO files to Obsidian";
        Service = {
          Type      = "simple";
          ExecStart = "${linkScript}";
          Restart   = "always";
          RestartSec = "5";
          StandardOutput = "journal";
          StandardError  = "journal";
        };
        Install.WantedBy = [ "default.target" ];
      };
    };
  };
}
