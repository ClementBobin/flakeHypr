{ lib, config }:

let
  cfg = config.desktops.hydenix;
  utilities = config.modules.hm.utilities;

  iannyOptions = utilities.safety.ianny;

  kandoEnabled = utilities.app-launcher.kando.enable;

  # Generate random command logic
  randomCommand =
    if cfg.randomOnBoot.wallpaper && cfg.randomOnBoot.theme then
      "random-theme.sh -a"
    else if cfg.randomOnBoot.wallpaper then
      "wallpaper.sh -r"
    else if cfg.randomOnBoot.theme then
      "random-theme.sh -r"
    else
      null;

  startupCmds = [
    "sleep 1"
    (lib.optionalString kandoEnabled "kando")
    (lib.optionalString (randomCommand != null) randomCommand)
  ];
  filteredCmds = lib.filter (x: x != "") startupCmds;
  execCmd = lib.concatStringsSep " && " filteredCmds;
in
{
  hyprlandKeybinds = ''
    ## █▄▀ █▀▀ █▄█ █▄▄ █ █▄░█ █▀▄ █ █▄░█ █▀▀ █▀
    ## █░█ ██▄ ░█░ █▄█ █ █░▀█ █▄▀ █ █░▀█ █▄█ ▄█
    # $scrPath=$HOME/.local/lib/hyde # set scripts path

    $l=Launcher
    $d=[$l|Rofi menus]
    bindd = $mainMod, colon, $d keybindings hint, exec, pkill -x rofi || $scrPath/keybinds_hint.sh c # launch keybinds hint
    bindd = $mainMod, semicolon , $d glyph picker , exec, pkill -x rofi || $scrPath/glyph-picker.sh # launch glyph picker
    ${lib.optionalString kandoEnabled ''
      bindd = Alt, Space, $d launch Kando app launcher, global, menu.kando.Kando:hypr
    ''}

    $ws=Workspaces
    $d=[$ws|Navigation]
    bindd = $mainMod, ampersand, $d navigate to workspace 1 , workspace, 1
    bindd = $mainMod, eacute, $d navigate to workspace 2 , workspace, 2
    bindd = $mainMod, quotedbl, $d navigate to workspace 3 , workspace, 3
    bindd = $mainMod, apostrophe, $d navigate to workspace 4 , workspace, 4
    bindd = $mainMod, parenleft, $d navigate to workspace 5 , workspace, 5
    bindd = $mainMod, minus, $d navigate to workspace 6 , workspace, 6
    bindd = $mainMod, egrave, $d navigate to workspace 7 , workspace, 7
    bindd = $mainMod, underscore, $d navigate to workspace 8 , workspace, 8
    bindd = $mainMod, ccedilla, $d navigate to workspace 9 , workspace, 9
    bindd = $mainMod, agrave, $d navigate to workspace 10 , workspace, 10

    # Move focused window to a workspace
    $d=[$ws|Move window to workspace]
    bindd = $mainMod Shift, ampersand, $d move to workspace 1 , movetoworkspace, 1
    bindd = $mainMod Shift, eacute, $d move to workspace 2 , movetoworkspace, 2
    bindd = $mainMod Shift, quotedbl, $d move to workspace 3 , movetoworkspace, 3
    bindd = $mainMod Shift, apostrophe, $d move to workspace 4 , movetoworkspace, 4
    bindd = $mainMod Shift, parenleft, $d move to workspace 5 , movetoworkspace, 5
    bindd = $mainMod Shift, minus, $d move to workspace 6 , movetoworkspace, 6
    bindd = $mainMod Shift, egrave, $d move to workspace 7 , movetoworkspace, 7
    bindd = $mainMod Shift, underscore, $d move to workspace 8 , movetoworkspace, 8
    bindd = $mainMod Shift, ccedilla, $d move to workspace 9 , movetoworkspace, 9
    bindd = $mainMod Shift, agrave, $d move to workspace 10 , movetoworkspace, 10

    # Move focused window to a workspace silently
    $d=[$ws|Navigation|Move window silently]
    bindd = $mainMod Alt, ampersand, $d move to workspace 1  (silent), movetoworkspacesilent, 1
    bindd = $mainMod Alt, eacute, $d move to workspace 2  (silent), movetoworkspacesilent, 2
    bindd = $mainMod Alt, quotedbl, $d move to workspace 3  (silent), movetoworkspacesilent, 3
    bindd = $mainMod Alt, apostrophe, $d move to workspace 4  (silent), movetoworkspacesilent, 4
    bindd = $mainMod Alt, parenleft, $d move to workspace 5  (silent), movetoworkspacesilent, 5
    bindd = $mainMod Alt, minus, $d move to workspace 6  (silent), movetoworkspacesilent, 6
    bindd = $mainMod Alt, egrave, $d move to workspace 7  (silent), movetoworkspacesilent, 7
    bindd = $mainMod Alt, underscore, $d move to workspace 8  (silent), movetoworkspacesilent, 8
    bindd = $mainMod Alt, ccedilla, $d move to workspace 9  (silent), movetoworkspacesilent, 9
    bindd = $mainMod Alt, agrave, $d move to workspace 10 (silent), movetoworkspacesilent, 10

    $ws=Modes
    $d=[$ws|Safety]
    ${lib.optionalString iannyOptions.enable ''
      bindd = $mainMod, F1, $d toggle safety mode, exec, toggle-ianny
      ${ lib.optionalString (iannyOptions.mode == "preset") ''
        bindd = $mainMod, F2, $d select Ianny preset, exec, ianny-preset-selector
        ${lib.optionalString (builtins.elem "game" iannyOptions.presets) ''
          bindd = $mainMod Alt, G, $d activate game preset, exec, ianny-preset-selector --game
        ''}
      ''}
    ''}
    bindd = $mainMod Alt, F4, $d emergency shutdown all apps, exec, pkill -KILL -u $USER

    $d=#! unset the group name
  '';

  exec-once = ''
    exec-once = ${execCmd}
  '';

  config = ''
    ${lib.optionalString kandoEnabled ''
      ### kando Section
      input {
        special_fallthrough = true # having only floating windows in the special workspace will not block focusing windows in the regular workspace.
        focus_on_close = 1 # focus will shift to the window under the cursor.
      }

      windowrule = noblur, class:kando
      windowrule = opaque, class:kando
      windowrule = size 100% 100%, class:kando
      windowrule = noborder, class:kando
      windowrule = noanim, class:kando
      windowrule = float, class:kando
      windowrule = pin, class:kando

      ###
    ''}
  '';
}