{
  config,
  ...
}:

{
  imports = [
    ../../common
  ];

  config.modules.common = {
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
      minecraft.enable = true;
    };
    multimedia = {
      gimp.enable = true;
      stremio.enable = true;
    };
    driver = {
      chrome.enable = true;
    };
    documentation = {
      obsidian = {
        enable = true;
        backupMethod  = "git-push-temp";
      };
      onlyoffice.enable = true;
    };
    dev = {
      editor = {
        dbeaver.enable = true;
        jetbrains.enable = true;
        vs-code.enable = true;
      };
      dotnet.enable = true;
      flutter.enable = true;
      global-tools = {
        act-github.enable = true;
        nix.enable = true;
      };
      node = {
        enable = true;
        graphite.enable = true;
        vercel.enable = true;
        localtunnel.enable = true;
      };
      python = {
        enable = true;
        devShell.enable = true;
      };
    };
    communication = {
      teams.enable = true;
      mail = {
        bluemail.enable = false;
        thunderbird.enable = true;
      };
    };
    utilities.scalar.enable = false;
  };
}
