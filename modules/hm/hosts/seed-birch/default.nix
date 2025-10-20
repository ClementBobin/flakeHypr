{
  config,
  ...
}:

{
  imports = [
    ../../common
  ];

  config = {
    modules.hm = {
      #nh.flakePath = "~/Documents/dev/multi-stack-project/nixos/flakeHypr";
      shell = {
        tools.enable = true;
        disk-usage.tools = ["gdu"];
      };
      games = {
        mangohud.enable = true;
        enabledGames = ["minecraft"];
      };
      multimedia = {
        editing.image.enable = true;
        editing.audio.enable = true;
        player = {
          clients = ["mpv" "miru"];
        };
        remote-desktop.clients = ["rustdesk"];
      };
      browser.clients = ["firefox"];
      documentation = {
        editors = ["onlyoffice"];
        obsidian.enable = true;
      };
      dev = {
        environments.ides = ["vs-code"];
        tools.nix.enable = true;
      };
      communication = {
        teams.enable = true;
        mail.services = ["bluemail"];
      };
      utilities.safety.ianny = {
        enable = true;
        presets = ["safety" "game"];
        defaultPreset = "safety";
      };
      extra.syncthing-ignore.enable = true;
    };
  };
}
