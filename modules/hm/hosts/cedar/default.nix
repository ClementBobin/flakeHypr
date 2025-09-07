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
      tools.enable = true;
      disk-usage.tools = [ "gdu" ];
    };
    dev = {
      environments.containers = {
        engine = [ "podman" ];
        enableSocket = true;
        hostUid = 1001;
        tui.enable = true;
        overrideAliases = true;
      };
      languages = {
        dotnet = {
          enable = true;
          extraPackages = [ "dotnet-ef" ];
        };
        node.enable = true;
        python.enable = true;
      };
      tools = {
        git-action.packages = [ "wrkflw" ];
        nix.enable = true;
        prisma.enable = true;
        gitleaks.enable = true;
      };
    };
    network.tunnel = {
      services = ["localtunnel"];
      localtunnel.port = 8080;
    };
    extra.syncthing-ignore = {
      enable = true;
      runAtStartup = true;
      excludedDirs = [ "node_modules" "vendor" "dist" "build" ".cache" ];
    };
  };
}
