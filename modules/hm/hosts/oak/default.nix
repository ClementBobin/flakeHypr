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
    };
    games = {
      mangohud.enable = false;
      minecraft.enable = true;
    };
    security = {
      clamav.enable = true;
      stacer.enable = true;
    };
    multimedia = {
      gimp.enable = true;
      stremio.enable = true;
    };
    driver = {
      chrome.enable = true;
    };
    documentation = {
      obsidian.enable = false;
      onlyoffice.enable = true;
    };
    dev = {
      dbeaver.enable = true;
      dotnet.enable = true;
      flutter.enable = true;
      jetbrains.enable = true;
      nix.enable = true;
      node.enable = true;
      python.enable = true;
    };
    communication = {
      teams.enable = true;
    };
  };
}
