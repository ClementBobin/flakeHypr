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
      starship.enable = true;
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
      clients = ["chrome" "firefox"];
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
      dotnet.enable = true;
      global-tools = {
        act-github.enable = true;
        nix.enable = true;
        cli = ["vercel" "graphite"];
      };
      node = {
        enable = true;
        prisma.enable = true;
      };
      python = {
        enable = true;
        devShell.enable = true;
      };
    };
    communication = {
      teams.enable = true;
      mail.services = ["thunderbird"];
    };
    network.tunnel = {
      services = ["localtunnel"];
      localtunnel.port = 8080;
    };
    utilities.scalar.enable = true;
    #extra = {
      #ignore-file-retriever = {
        #enable = true;
        #watchMode = true;
        #watchPaths = [ "~/Documents" ];
      #};
    #};
  };
}
