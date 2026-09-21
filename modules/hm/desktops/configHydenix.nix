{ lib, config }:

let
  cfg = config.desktops.hydenix;
  utilities = config.modules.hm.utilities;

  wallpaper-engineEnabled = config.modules.hm.multimedia.wallpaper-engine.enable;

  startupCmds = [
    "sleep 5"
  ];
  filteredCmds = lib.filter (x: x != "") startupCmds;
  execCmd = lib.concatStringsSep " && " filteredCmds;
in
{
  hyprlandConfig = ''
    local MOD = hyde.config.modifiers.main

    hl.config({
      input = {
        kb_layout = "fr",
        force_no_accel = true,
        accel_profile = "flat",
        sensitivity = 0,
      }
    })


    local kp_fr = {
      [1]  = "ampersand",
      [2]  = "eacute",
      [3]  = "quotedbl",
      [4]  = "apostrophe",
      [5]  = "parenleft",
      [6]  = "minus",
      [7]  = "egrave",
      [8]  = "underscore",
      [9]  = "ccedilla",
      [10] = "agrave",
    }

    for i = 1, 10 do
      _F = {description = "[Workspaces|Navigation] navigate to workspace " .. i}
      hl.bind(MOD .. " + " .. kp_fr[i], hl.dsp.focus({workspace = i}), _F)
    end

    for i = 1, 10 do
      _F = {description = "[Workspaces|Move window to workspace] move to workspace " .. i}
      hl.bind(MOD .. " + SHIFT + " .. kp_fr[i], hl.dsp.window.move({workspace = i}), _F)
    end

    for i = 1, 10 do
      _F = {description = "[Workspaces|Move window (Don't follow)] move silently to workspace " .. i}
      hl.bind(MOD .. " + ALT + " .. kp_fr[i], hl.dsp.window.move({workspace = i, follow = false}), _F)
    end


    ${lib.optionalString wallpaper-engineEnabled ''
      _F = {description = "[Launcher] wallpaper engine"}
      hl.bind(MOD .. " + SHIFT + Z", hl.dsp.exec_cmd("linux-wallpaper-engine"), _F)
    ''}

    _F = {description = "[Launcher|Apps] spotify"}
    hl.bind(MOD .. " + M", hl.dsp.exec_cmd("spotify"), _F)

    _F = {description = "[Launcher|Apps] obsidian"}
    hl.bind(MOD .. " + O", hl.dsp.exec_cmd("obsidian"), _F)

    _F = {description = "[Workflows & Power] toggle performance/default/powersaver"}
    hl.bind(MOD .. " + ALT + G", hl.dsp.exec_cmd("power-tools toggle"), _F)

    -- Rofi and utility launchers translated to Lua bindings
    _F = {description = "[Launcher|Rofi menus] keybindings hint"}
    hl.bind(MOD .. " + colon", hl.dsp.exec_cmd(hyde.sh.menu.binds()), _F)

    _F = {description = "[Launcher|Rofi menus] glyph picker"}
    hl.bind(MOD .. " + semicolon", hl.dsp.exec_cmd(hyde.sh.menu.glyph()), _F)

    _F = {description = "[Launcher|Rofi menus] Web Search"}
    hl.bind(MOD .. " + SHIFT + colon", hl.dsp.exec_cmd(hyde.sh.menu.search()), _F)

    -- Safety / Emergency shutdown
    _F = {description = "[Modes|Safety] emergency shutdown all apps"}
    hl.bind(MOD .. " + ALT + F4", hl.dsp.exec_cmd("pkill -KILL -u $USER"), _F)

    -- Open workflow selector with rofi
    _F = {description = "[Launcher|Rofi menus] workflow selector"}
    hl.bind(MOD .. " + SHIFT + S", hl.dsp.exec_cmd("hyde-shell workflows --select"), _F)

    -- Toggle between US and FR keyboard layouts with setxkbmap and send a notification
    _F = {description = "[Keyboard|Layout] toggle between US and FR layouts"}
    hl.bind(MOD .. " + SHIFT + K", hl.dsp.exec_cmd("bash -c 'if setxkbmap -query | grep -q \"layout:[[:space:]]*fr\"; then setxkbmap us && notify-send \"Keyboard\" \"Switched to US\"; else setxkbmap fr && notify-send \"Keyboard\" \"Switched to FR\"; fi'"), _F)

    -- Toggle between editing and previous workflow with hyde-shell and send a notification
    _F = {description = "[Workflow|Toggle] toggle between editing and previous workflow"}
    hl.bind(MOD .. " + SHIFT + C", hl.dsp.exec_cmd("bash -c 'current=$(hyde-shell workflows --current); if echo \"$current\" | grep -qi \"editing\"; then hyde-shell workflows --set Default; notify-send \"Workflow\" \"Switched to Default\"; else hyde-shell workflows --set Editing; notify-send \"Workflow\" \"Switched to Editing\"; fi'"), _F)
  '';
}