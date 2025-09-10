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
        editing.image.enable = true;
        player = {
          clients = ["mpv" "jellyfin" "miru"];
          jellyfin.rpc = true;
        };
        rambox.enable = true;
      };
      browser.clients = ["firefox"];
      documentation = {
        editors = ["onlyoffice"];
        obsidian.enable = true;
      };
      dev = {
        environments = {
          ides = ["vs-code" "android-studio" "datagrip" "webstorm" "phpstorm" "rider"];
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
          node = {
            enable = true;
            extraPackages = ["node2nix" "fnm" "npm-check-updates"];
          };
          python.enable = true;
        };
        tools = {
          git-action.packages = ["wrkflw"];
          nix.enable = true;
          gitleaks.enable = true;
          prisma.enable = true;
        };
      };
      communication = {
        teams.enable = true;
        mail.services = ["bluemail"];
        discord.rpc.enable = true;
        matrix.clients = ["element"];
      };
      utilities = {
        api = {
          scalar.enable = true;
          autoswagger.enable = true;
        };
        safety.ianny = {
          enable = true;
          presets = ["dev" "game"];
          defaultPreset = "dev";
        };
      };
      extra.syncthing-ignore = {
        enable = true;
        excludedDirs = ["node_modules" "vendor" "storage" ".idea"];
      };
    };
  };
}
