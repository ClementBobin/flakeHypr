{ lib }:

{
  hyprlandKeybindsConvert = ''
    ## █▄▀ █▀▀ █▄█ █▄▄ █ █▄░█ █▀▄ █ █▄░█ █▀▀ █▀
    ## █░█ ██▄ ░█░ █▄█ █ █░▀█ █▄▀ █ █░▀█ █▄█ ▄█
    # $scrPath=$HOME/.local/lib/hyde # set scripts path


    $l=Launcher
    $d=[$l|Rofi menus]
    bindd = $mainMod, colon, $d keybindings hint, exec, pkill -x rofi || $scrPath/keybinds_hint.sh c # launch keybinds hint
    bindd = $mainMod, semicolon , $d glyph picker , exec, pkill -x rofi || $scrPath/glyph-picker.sh # launch glyph picker

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

    $d=#! unset the group name
  '';
}