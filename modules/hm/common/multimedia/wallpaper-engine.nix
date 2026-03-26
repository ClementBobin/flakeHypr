{ pkgs, lib, config, inputs, ... }:

# ── Wallpaper Engine integration for HyDE / Hyprland ─────────────────────────
#
# Installs two packages:
#   • pkgs.linux-wallpaperengine  — the renderer (Almamu), runs as background
#   • jagrat7/linux-wallpaper-engine (flake) — GUI to browse/configure/launch
#
# A virtual HyDE theme called "Wallpaper Engine" (configurable) is registered
# in ~/.config/hyde/themes/ so it appears in the HyDE theme picker alongside
# Tokyo Night, Pixel Dream, etc.
#
# Theme files (hypr.theme, waybar.theme, rofi.theme, kitty.theme) are generated
# at activation time by reading colors from the currently-active HyDE theme.
# If no active theme is found, a universal dark-neutral fallback is used.
#
# A systemd user service watches the active HyDE theme and:
#   • starts  linux-wallpaperengine when you switch TO  the WE theme
#   • stops   linux-wallpaperengine when you switch AWAY (swww resumes)
# ─────────────────────────────────────────────────────────────────────────────

let
  cfg = config.modules.hm.multimedia.wallpaper-engine;

  themeDir = "$HOME/.config/hyde/themes/${cfg.themeName}";

  # ── Color extraction helper (runs at activation / service start) ──────────
  # Tries to read $background / $accent from the active theme's colors.conf.
  # Falls back to a dark-neutral palette that pairs with any HyDE theme.
  colorExtractScript = pkgs.writeShellScript "we-extract-colors" ''
    set -euo pipefail

    HYDE_CONFIG="$HOME/.config/hyde/config"
    THEMES_DIR="$HOME/.config/hyde/themes"

    # ── Read active theme name ────────────────────────────────────────────────
    active_theme() {
      grep -oP '(?<=^export\s+hydeTheme=)["\x27]?\K[^"'"'"'\n]+' \
        "$HYDE_CONFIG" 2>/dev/null | head -1 || echo ""
    }

    ACTIVE="$(active_theme)"
    COLORS_FILE="$THEMES_DIR/$ACTIVE/hypr.theme"

    # ── Parse a Hyprland rgba() color to hex ─────────────────────────────────
    # HyDE stores colors as rgba(rrggbbaa) or 0xrrggbb — we want bare rrggbb
    parse_hex() {
      echo "$1" \
        | grep -oP '[0-9a-fA-F]{6}' \
        | head -1
    }

    # Defaults — dark neutral, works with any theme
    BG="18181b"      # zinc-900
    BG2="27272a"     # zinc-800
    FG="e4e4e7"      # zinc-200
    ACCENT="60a5fa"  # blue-400 — visible on dark, unobtrusive on light
    ACCENT2="a78bfa" # violet-400
    BORDER="3f3f46"  # zinc-700

    if [[ -f "$COLORS_FILE" ]]; then
      # Try to pull col.active_border first color
      RAW_ACCENT="$(grep -oP '(?<=col\.active_border\s=\s)rgba\([0-9a-fA-F]+\)' \
        "$COLORS_FILE" 2>/dev/null | head -1 || true)"
      RAW_BG="$(grep -oP '(?<=col\.inactive_border\s=\s)rgba\([0-9a-fA-F]+\)' \
        "$COLORS_FILE" 2>/dev/null | head -1 || true)"

      [[ -n "$RAW_ACCENT" ]] && ACCENT="$(parse_hex "$RAW_ACCENT")" || true
      [[ -n "$RAW_BG"     ]] && BORDER="$(parse_hex "$RAW_BG")"     || true
    fi

    # Export for use by callers
    echo "BG=$BG"
    echo "BG2=$BG2"
    echo "FG=$FG"
    echo "ACCENT=$ACCENT"
    echo "ACCENT2=$ACCENT2"
    echo "BORDER=$BORDER"
  '';

  # ── Theme scaffold generator ───────────────────────────────────────────────
  # Creates all required HyDE theme files under ~/.config/hyde/themes/<name>/
  # Matches the structure from your example:
  #   hypr.theme  kitty.theme  rofi.theme  waybar.theme  wallpapers/wallpaper.png
  themeGenScript = pkgs.writeShellScript "we-gen-theme" ''
    set -euo pipefail

    THEME_DIR="${themeDir}"
    THEME_NAME=${lib.escapeShellArg cfg.themeName}

    # Load colors (eval the key=value pairs from the extractor)
    eval "$(${colorExtractScript})"

    mkdir -p "$THEME_DIR/wallpapers"

    # ── Placeholder 1×1 black PNG (required by HyDE picker) ──────────────────
    if [[ ! -f "$THEME_DIR/wallpapers/wallpaper.png" ]]; then
      printf '%s' \
        'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk' \
        '+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg==' \
        | base64 -d > "$THEME_DIR/wallpapers/wallpaper.png"
    fi

    # Symlinks HyDE expects
    ln -sf "$THEME_DIR/wallpapers/wallpaper.png" "$THEME_DIR/wall.set"
    ln -sf "$THEME_DIR/wallpapers/wallpaper.png" "$THEME_DIR/wall.swww.png"
    ln -sf "$THEME_DIR/wallpapers/wallpaper.png" "$THEME_DIR/wall.hyprlock.png"

    # ── hypr.theme ────────────────────────────────────────────────────────────
    cat > "$THEME_DIR/hypr.theme" <<EOF
\$GTK_THEME = adw-gtk3-dark
\$ICON_THEME = Papirus-Dark
\$COLOR_SCHEME = prefer-dark

exec = gsettings set org.gnome.desktop.interface icon-theme \$ICON_THEME
exec = gsettings set org.gnome.desktop.interface gtk-theme \$GTK_THEME
exec = gsettings set org.gnome.desktop.interface color-scheme \$COLOR_SCHEME

general {
    gaps_in = 3
    gaps_out = 8
    border_size = 2
    col.active_border  = rgba(''${ACCENT}ff) rgba(''${ACCENT2}ff) 45deg
    col.inactive_border = rgba(''${BORDER}cc) rgba(''${BG2}cc) 45deg
    layout = dwindle
    resize_on_border = true
}

group {
    col.border_active          = rgba(''${ACCENT}ff) rgba(''${ACCENT2}ff) 45deg
    col.border_inactive        = rgba(''${BORDER}cc) rgba(''${BG2}cc) 45deg
    col.border_locked_active   = rgba(''${ACCENT}ff) rgba(''${ACCENT2}ff) 45deg
    col.border_locked_inactive = rgba(''${BORDER}cc) rgba(''${BG2}cc) 45deg
}

decoration {
    rounding = 10
    shadow:enabled = false

    blur {
        enabled          = yes
        size             = 6
        passes           = 3
        new_optimizations = on
        ignore_opacity   = on
        xray             = false
    }
}

layerrule = blur,waybar
EOF

    # ── kitty.theme ───────────────────────────────────────────────────────────
    cat > "$THEME_DIR/kitty.theme" <<EOF
# Wallpaper Engine theme — auto-derived neutral palette
foreground #''${FG}
background #''${BG}

color0  #''${BG2}
color8  #''${BG2}
color1  #f87171
color9  #f87171
color2  #86efac
color10 #86efac
color3  #fde68a
color11 #fde68a
color4  #''${ACCENT}
color12 #''${ACCENT}
color5  #''${ACCENT2}
color13 #''${ACCENT2}
color6  #67e8f9
color14 #67e8f9
color7  #''${FG}
color15 #''${FG}

cursor            #''${FG}
cursor_text_color #''${BG}
selection_foreground none
selection_background #''${BORDER}
url_color #86efac

active_border_color   #''${ACCENT}
inactive_border_color #''${BORDER}
bell_border_color     #fde68a

tab_bar_style              fade
tab_fade                   1
active_tab_foreground      #''${ACCENT}
active_tab_background      #''${BG}
active_tab_font_style      bold
inactive_tab_foreground    #''${BORDER}
inactive_tab_background    #''${BG}
inactive_tab_font_style    bold
tab_bar_background         #''${BG2}
macos_titlebar_color       #''${BG}
EOF

    # ── rofi.theme ────────────────────────────────────────────────────────────
    cat > "$THEME_DIR/rofi.theme" <<EOF
* {
    main-bg:        #''${BG}e6;
    main-fg:        #''${FG}ff;
    main-br:        #''${ACCENT}ff;
    main-ex:        #''${ACCENT2}cc;
    select-bg:      #''${ACCENT}ff;
    select-fg:      #''${BG}ff;
    separatorcolor: transparent;
    border-color:   transparent;
}
EOF

    # ── waybar.theme ──────────────────────────────────────────────────────────
    cat > "$THEME_DIR/waybar.theme" <<EOF
/* Wallpaper Engine theme — auto-derived */
@define-color bar-bg    rgba(0, 0, 0, 0.15);
@define-color main-bg   #''${BG};
@define-color main-fg   #''${ACCENT};
@define-color wb-act-bg #''${ACCENT};
@define-color wb-act-fg #''${ACCENT2};
@define-color wb-hvr-bg #''${ACCENT2};
@define-color wb-hvr-fg #''${FG};
EOF

    echo "[WE-theme-gen] Theme files written to $THEME_DIR"
  '';

  # ── Theme-watcher script ──────────────────────────────────────────────────
  themeWatcher = pkgs.writeShellScript "wallpaper-engine-theme-watcher" ''
    set -euo pipefail

    THEME_NAME=${lib.escapeShellArg cfg.themeName}
    HYDE_CONFIG="$HOME/.config/hyde/config"
    LAST_THEME=""
    RUNNER_UNIT="wallpaper-engine-runner.service"

    active_theme() {
      grep -oP '(?<=^export\s+hydeTheme=)["\x27]?\K[^"'"'"'\n]+' \
        "$HYDE_CONFIG" 2>/dev/null | head -1 || echo ""
    }

    echo "[WE-watcher] Started. Watching for theme: $THEME_NAME"

    while true; do
      CURRENT="$(active_theme)"

      if [[ "$CURRENT" != "$LAST_THEME" ]]; then
        echo "[WE-watcher] Theme: '$LAST_THEME' -> '$CURRENT'"
        LAST_THEME="$CURRENT"

        if [[ "$CURRENT" == "$THEME_NAME" ]]; then
          echo "[WE-watcher] Wallpaper Engine theme active -- regenerating colors and starting."
          # Regenerate theme files to inherit colors from the previous theme
          ${themeGenScript} || true
          systemctl --user start "$RUNNER_UNIT" || true
        else
          echo "[WE-watcher] Other theme active -- stopping."
          systemctl --user stop "$RUNNER_UNIT" || true
        fi
      fi

      sleep 2
    done
  '';

in
{
  # ── Options ─────────────────────────────────────────────────────────────────
  options.modules.hm.multimedia.wallpaper-engine = {

    enable = lib.mkEnableOption
      "linux-wallpaperengine + jagrat7 GUI, integrated with the HyDE theme system";

    themeName = lib.mkOption {
      type    = lib.types.str;
      default = "Wallpaper Engine";
      description = ''
        Name of the virtual HyDE theme that triggers linux-wallpaperengine.
        Appears in the HyDE theme picker alongside Tokyo Night, Pixel Dream, …
        Selecting it starts the engine; switching away stops it so swww resumes.
      '';
    };

    isDefault = lib.mkOption {
      type    = lib.types.bool;
      default = false;
      description = ''
        Activate the Wallpaper Engine theme on every login.
        When false, pick it manually in the HyDE theme picker.
      '';
    };
  };

  # ── Implementation ─────────────────────────────────────────────────────────
  config = lib.mkIf cfg.enable {

    # ── Packages ──────────────────────────────────────────────────────────────
    home.packages = [
      pkgs.linux-wallpaperengine
      inputs.linux-wallpaper-engine.packages.${pkgs.stdenv.hostPlatform.system}.default
    ];

    # ── Generate theme files at activation time ───────────────────────────────
    # Creates hypr.theme, kitty.theme, rofi.theme, waybar.theme under
    # ~/.config/hyde/themes/<themeName>/ with colors derived from the active
    # HyDE theme (or the built-in dark-neutral fallback).
    home.activation.wallpaperEngineGenTheme =
      lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        ${themeGenScript}
      '';

    # ── Runner service — started/stopped by the watcher ───────────────────────
    # Uncomment and adapt ExecStart to your preferred launch method.
    # systemd.user.services.wallpaper-engine-runner = {
    #   Unit = {
    #     Description = "linux-wallpaperengine runner (managed by theme-watcher)";
    #     After       = [ "graphical-session.target" ];
    #   };
    #   Service = {
    #     Type      = "simple";
    #     ExecStart = pkgs.writeShellScript "we-runner" ''
    #       LAUNCH="$HOME/.config/linux-wallpaper-engine/launch.sh"
    #       if [[ -x "$LAUNCH" ]]; then
    #         exec "$LAUNCH"
    #       else
    #         exec ${lib.getExe pkgs.linux-wallpaperengine} "$@"
    #       fi
    #     '';
    #     Restart    = "on-failure";
    #     RestartSec = "3";
    #   };
    # };

    # ── Theme-watcher service ─────────────────────────────────────────────────
    systemd.user.services.wallpaper-engine-theme-watcher = {
      Unit = {
        Description = "HyDE theme watcher — start/stop linux-wallpaperengine";
        After       = [ "graphical-session.target" ];
        PartOf      = [ "graphical-session.target" ];
      };
      Service = {
        Type         = "simple";
        ExecStartPre = "${pkgs.coreutils}/bin/sleep 10";
        ExecStart    = "${themeWatcher}";
        Restart      = "on-failure";
        RestartSec   = "5";
      };
      Install.WantedBy = [ "graphical-session.target" ];
    };

    # ── Optional: activate theme on every login ───────────────────────────────
    home.activation.wallpaperEngineSetDefaultTheme = lib.mkIf cfg.isDefault (
      lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        CONFIG="$HOME/.config/hyde/config"
        if [[ -f "$CONFIG" ]]; then
          if grep -q '^export hydeTheme=' "$CONFIG"; then
            sed -i \
              's|^export hydeTheme=.*|export hydeTheme="${cfg.themeName}"|' \
              "$CONFIG"
          else
            echo 'export hydeTheme="${cfg.themeName}"' >> "$CONFIG"
          fi
        fi
      ''
    );
  };
}
