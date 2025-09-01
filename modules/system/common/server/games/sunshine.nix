{ config, lib, pkgs, vars, ... }:

let
  cfg = config.modules.system.server.games.sunshine;
in
{
  options.modules.system.server.games.sunshine = {
    enable = lib.mkEnableOption "Sunshine streaming server";

    allowedNetworks = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [
        "192.168.0.0/16"
        "10.0.0.0/8"
      ];
      description = "Networks allowed to connect to Sunshine";
    };

    settings = lib.mkOption {
      type = lib.types.attrs;
      default = {
        # key_rightalt_to_key_win = "enabled";
        adapter_name = "/dev/dri/renderD128";
      };
      description = "Sunshine configuration settings";
    };

    applications = lib.mkOption {
      type = lib.types.listOf (lib.types.submodule {
        options = {
          name = lib.mkOption {
            type = lib.types.str;
            description = "Name of the application profile";
          };
          output = lib.mkOption {
            type = lib.types.str;
            description = "Output display for this profile";
          };
          autoDetach = lib.mkOption {
            type = lib.types.bool;
            default = true;
            description = "Whether to auto-detach after session ends";
          };
          prepCommands = lib.mkOption {
            type = lib.types.submodule {
              options = {
                do = lib.mkOption {
                  type = lib.types.str;
                  description = "Command to run when starting stream";
                };
                undo = lib.mkOption {
                  type = lib.types.str;
                  description = "Command to run when ending stream";
                };
              };
            };
            description = "Preparation commands for this profile";
          };
        };
      });
      default = [
        {
          name = "Programming Mode (Note 11 2400*1080)";
          output = "DP-5";
          autoDetach = true;
          prepCommands = {
            do = ''
              sed -i 's/\$mainMod = Super/\$mainMod = ALT_R/' ~/.config/hypr/keybindings.conf
              ${pkgs.hyprland}/bin/hyprctl keyword input:kb_layout "us"
              ${pkgs.hyprland}/bin/hyprctl keyword monitor DP-4,disable
              ${pkgs.hyprland}/bin/hyprctl keyword monitor DP-6,disable
              ${pkgs.hyprland}/bin/hyprctl keyword monitor DP-5,addreserved,0,0,0,0
              ${pkgs.hyprland}/bin/hyprctl keyword monitor DP-5,2320x1080@60,0x0,2
              ${pkgs.hyprland}/bin/hyprctl keyword misc:cursor_zoom_factor 2
              ${pkgs.hyprland}/bin/hyprctl keyword misc:no_direct_scanout 1
            '';
            undo = ''
              sed -i 's/\$mainMod = ALT_R/\$mainMod = Super/' ~/.config/hypr/keybindings.conf
              Hyde reload
              ${pkgs.hyprland}/bin/hyprctl reload
            '';
          };
        }
        {
          name = "Mobile Stream (1080p)";
          output = "DP-5";
          autoDetach = true;
          prepCommands = {
            do = ''
              ${pkgs.hyprland}/bin/hyprctl keyword monitor DP-4,disable
              ${pkgs.hyprland}/bin/hyprctl keyword monitor DP-6,disable
              sleep 1
              ${pkgs.hyprland}/bin/hyprctl keyword monitor DP-5,2560x1440@144,0x0,1.6
              ${pkgs.hyprland}/bin/hyprctl keyword misc:cursor_zoom_factor 1.6
            '';
            undo = ''
              ${pkgs.hyprland}/bin/hyprctl reload
            '';
          };
        }
        {
          name = "Mobile Stream (Performance)";
          output = "DP-5";
          autoDetach = true;
          prepCommands = {
            do = ''
              ${pkgs.hyprland}/bin/hyprctl keyword monitor DP-4,disable
              ${pkgs.hyprland}/bin/hyprctl keyword monitor DP-6,disable
              sleep 1
              ${pkgs.hyprland}/bin/hyprctl keyword monitor DP-5,1920x1080@144,0x0,1.25
              ${pkgs.hyprland}/bin/hyprctl keyword misc:cursor_zoom_factor 1.25
            '';
            undo = ''
              ${pkgs.hyprland}/bin/hyprctl reload
            '';
          };
        }
      ];
      description = "Application profiles for Sunshine streaming";
    };

    environment = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      default = {
        PATH = "$(PATH):$(HOME)/.local/bin";
      };
      description = "Environment variables for Sunshine applications";
    };

    openFirewall = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Whether to open firewall ports for Sunshine";
    };

    autoStart = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Whether to start Sunshine automatically";
    };

    capSysAdmin = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Whether to grant CAP_SYS_ADMIN capability to Sunshine";
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [ sunshine ];

    services.sunshine = {
      enable = true;
      inherit (cfg) autoStart capSysAdmin openFirewall;
      settings = cfg.settings;
      applications = {
        env = cfg.environment;
        apps = map (app: {
          name = app.name;
          prep-cmd = [{
            do = pkgs.writeShellScript "${lib.strings.sanitizeDerivationName app.name}-do" app.prepCommands.do;
            undo = pkgs.writeShellScript "${lib.strings.sanitizeDerivationName app.name}-undo" app.prepCommands.undo;
          }];
          auto-detach = lib.boolToString app.autoDetach;
          output = app.output;
        }) cfg.applications;
      };
    };

    users.groups.keyd.members = [ vars.user ];
    users.users.${vars.user}.extraGroups = [ "video" "input" "render" "kvm" "uinput" ];

    boot.kernelModules = [ "uinput" ];
    services.udev.extraRules = ''
      KERNEL=="uinput", SUBSYSTEM=="misc", MODE="0660", GROUP="input"
    '';

    networking.firewall.extraCommands = lib.concatMapStrings (net: ''
      iptables -A INPUT -p tcp -s ${net} --dport 47984:47990 -j ACCEPT
      iptables -A INPUT -p udp -s ${net} --dport 47998:48000 -j ACCEPT
    '') cfg.allowedNetworks;
  };
}