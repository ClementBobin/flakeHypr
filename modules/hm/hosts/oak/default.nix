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
          gpu.text = [ "RTX 4060 Laptop" "AMD Rembrandt" ];
        };
        enabledGames = ["minecraft"];
      };
      multimedia = {
        editing.image.enable = true;
        player = {
          clients = ["mpv" "jellyfin-client" "spicetify" "ani-cli" "mangayomi"];
          jellyfin.rpc = true;
        };
        remote-desktop.clients = ["remote-viewer"]; # "remmina"
        management-utility.clients = ["nwg-displays"];
      };
      browser.clients = ["zen"];
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
          node = {
            enable = true;
            extraPackages = ["node2nix" "fnm" "npm-check-updates"];
          };
          rust.enable = true;
          python.enable = true;
        };
        tools = {
          git-action.packages = ["act"];
          nix.enable = true;
          #gitleaks.enable = true;
          prisma.enable = true;
        };
      };
      communication = {
        teams.enable = true;
        mail.services = ["velo"];
        discord = {
          clients = ["fluxer"];
          rpc.enable = true;
        };
      };
      utilities = {
        api.clients = ["scalar"];
        tracker.enable = true;
        app-launcher.clients = ["hyprshell"];
      };
      extra.syncthing-ignore = {
        enable = true;
        excludedDirs = ["node_modules" "vendor" "storage" ".idea"];
      };
    };
  };
}
