{
  config,
  ...
}:

{
  imports = [
    ../../common
  ];

  config.modules.hm = {
    shell = {
      btop.enable = true;
      fzf.enable = true;
      ranger.enable = true;
      tools.enable = true;
      navi.enable = true;
    };
    games = {
      mangohud = {
        enable = true;
        cpu_text = "Ryzen 7 7435HS";
      };
      enabledGames = ["minecraft"];
    };
    multimedia = {
      gimp.enable = true;
      stremio.enable = true;
    };
    browser = {
      clients = ["firefox"];
      driver.enable = true;
    };
    documentation = {
      editors = ["onlyoffice"];
      obsidian = {
        enable = true;
        backupMethod  = "git-push-temp";
      };
    };
    dev = {
      editor = {
        dbeaver.enable = true;
        jetbrains.enable = true;
        vs-code.enable = true;
        android-studio.enable = true;
      };
      dotnet = {
        enable = true;
        extraPackages = [ "dotnet-ef" ];
      };
      global-tools = {
        act-github.enable = true;
        nix.enable = true;
      };
      node = {
        enable = true;
        prisma.enable = true;
      };
      python.enable = true;
    };
    communication = {
      teams.enable = true;
      mail.services = ["thunderbird"];
      discord.rpc.enable = true;
    };
    network.tunnel = {
      services = ["localtunnel"];
      localtunnel.port = 8080;
    };
    utilities.scalar.enable = true;
  };
}
