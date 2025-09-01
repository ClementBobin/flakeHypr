{ pkgs, lib, config, vars, ... }:

let
  cfg = config.modules.system.server.communication.deskflow;
in
{
  options.modules.system.server.communication.deskflow.enable = lib.mkEnableOption "Enable Deskflow server";

  config = lib.mkIf cfg.enable {
    environment.systemPackages = (with pkgs; [
      deskflow
    ]);
  };
}