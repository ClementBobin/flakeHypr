{ pkgs-unstable, lib, config, inputs, ... }:

# ── Wallpaper Engine integration for HyDE / Hyprland ─────────────────────────
#
# Installs two packages:
#   • pkgs-unstable.linux-wallpaperengine  — the renderer (Almamu), runs as background
#   • jagrat7/linux-wallpaper-engine (flake) — GUI to browse/configure/launch
#
# ─────────────────────────────────────────────────────────────────────────────

let
  cfg = config.modules.hm.multimedia.wallpaper-engine;
in
{
  # ── Options ─────────────────────────────────────────────────────────────────
  options.modules.hm.multimedia.wallpaper-engine.enable = lib.mkEnableOption "linux-wallpaperengine + jagrat7 GUI, integrated with the HyDE theme system";

  # ── Implementation ─────────────────────────────────────────────────────────
  config = lib.mkIf cfg.enable {
    # ── Packages ──────────────────────────────────────────────────────────────
    home.packages = [
      pkgs-unstable.linux-wallpaperengine
      inputs.linux-wallpaper-engine.packages.${pkgs-unstable.stdenv.hostPlatform.system}.default
    ];
  };
}
