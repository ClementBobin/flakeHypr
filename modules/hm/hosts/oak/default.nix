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
      nh.flakePath = "~/Documents/dev/multi-stack-project/nixos/flakeHypr";
      shell = {
        tools.enable = true;
        disk-usage.tools = ["gdu"];
      };
      games = {
        mangohud = {
          enable = true;
          cpu.text = ["Ryzen 7 7435HS"];
          gpu.text = [ "AMD Rembrandt" "RTX 4060 Laptop" ];
        };
        enabledGames = ["minecraft"];
      };
      multimedia = {
        wallpaper-engine.enable = true;
        editing.image.enable = true;
        player = {
          clients = ["mpv" "jellyfin-client"];
          jellyfin.rpc = true;
        };
      };
      documentation = {
        editors = ["onlyoffice"];
        obsidian.enable = true;
      };
      dev = {
        environments = {
          ides = ["vs-code" "datagrip" "rider"];
          containers = {
            engine = ["podman"];
            enableSocket = true;
            hostUid = 1001;
            tui.enable = true;
            overrideAliases = true;
          };
        };
        languages = {
          dotnet = {
            enable = true;
            extraPackages = ["dotnet-ef"];
          };
          node.enable = true;
          python.enable = true;
        };
        tools = {
          git-action.packages = ["act"];
          nix.enable = true;
          gitleaks.enable = false;
          prisma.enable = true;
          opencode.enable = true;
        };
      };
      communication = {
        teams.enable = true;
        mail.services = ["velo"];
      };
      utilities = {
        api.clients = ["scalar"];
        time-tracker.enabledTrackers = ["solidtime"];
      };
      # extra.syncthing-ignore = {
      #   enable = true;
      #   excludedDirs = ["node_modules" "vendor" "storage" ".idea"];
      # };
    };
  };
}
