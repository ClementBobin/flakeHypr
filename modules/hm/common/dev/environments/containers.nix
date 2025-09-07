{ pkgs, lib, config, ... }:

let
  cfg = config.modules.hm.dev.environments.containers;
  
  enginePackages = engine:
    if engine == "docker" then [ pkgs.docker-compose ]
    else if engine == "podman" then [ pkgs.podman-compose ]
    else [];

  hasDocker = lib.lists.elem "docker" cfg.engine;
  hasPodman = lib.lists.elem "podman" cfg.engine;
  onlyOneEngine = lib.length cfg.engine == 1;
in
{
  options.modules.hm.dev.environments.containers = {
    engine = lib.mkOption {
      type = lib.types.listOf (lib.types.enum ["docker" "podman"]);
      default = ["docker"];
      description = "List of container engines to use (docker and/or podman)";
    };
    gui.enable = lib.mkEnableOption "Enable GUI for container management";
    tui.enable = lib.mkEnableOption "Enable TUI for container management";
    helper.enable = lib.mkEnableOption "Enable helper tools for container management";
    overrideAliases = lib.mkEnableOption "Override all aliases for container management tools";
    enableSocket = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable socket activation for the container engine";
    };
    hostUid = lib.mkOption {
      type = lib.types.int;
      default = 1000;
      description = "User ID for the podman socket location";
    };
  };

  config = lib.mkMerge [
    {
      services.podman = lib.mkIf hasPodman {
        enable = true;
        #settings.containers.network.dns_bind_port = 1153;
      };

      systemd.user.sockets.podman = lib.mkIf (hasPodman && cfg.enableSocket) {
        Install.WantedBy = ["sockets.target"];
        Socket = {
          SocketMode = "0660";
          ListenStream = "/run/user/${toString cfg.hostUid}/podman/podman.sock";
        };
      };
      
      systemd.user.services.podman = lib.mkIf (hasPodman && cfg.enableSocket) {
        Install.WantedBy = ["default.target"];
        Service = {
          Delegate = true;
          Type = "exec";
          KillMode = "process";
          Environment = ["LOGGING=--log-level=info"];
          ExecStart = "${lib.getExe pkgs.podman} $LOGGING system service";
        };
      };
    }

    {
      home.packages = with pkgs;
        (lib.concatMap enginePackages cfg.engine)
        ++ lib.optionals cfg.gui.enable [ podman-desktop ]
        ++ lib.optionals cfg.tui.enable (
          lib.optional hasDocker dry ++ lib.optional hasPodman podman-tui
        )
        ++ lib.optionals cfg.helper.enable [ lazydocker ];
    }

    {
      home.shellAliases = lib.mkIf cfg.overrideAliases (
        if onlyOneEngine then
          if hasPodman then {
            docker = "podman";
            docker-compose = "podman-compose";
            docker-tui = "podman-tui";
          } else {
            podman = "docker";
            podman-compose = "docker-compose";
            docker-tui = "dry";
            docker-help = "lazydocker";
          }
        else
          {}
      );
    }

    {
      assertions = [
        {
          assertion = !(cfg.overrideAliases && lib.length cfg.engine > 1);
          message = ''
            Cannot safely override aliases with multiple container engines enabled.
            Either:
            1. Set modules.hm.dev.containers.overrideAliases = false
            2. Select only one engine in modules.hm.dev.containers.engine
          '';
        }
        {
          assertion = !(cfg.helper.enable && hasPodman);
          message = ''
            Podman does not require lazydocker as it has its own TUI.
            So:
            1. Set modules.hm.dev.containers.helper.enable = false
            2. Use podman-tui instead
          '';
        }
      ];
    }
  ];
}