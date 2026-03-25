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
        player.clients = ["mpv"];
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
      extra.syncthing-ignore.enable = true;
    };
  };
}
