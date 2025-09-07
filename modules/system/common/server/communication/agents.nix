{
  lib,
  config,
  ...
}:
let
  cfg = config.modules.system.server.communication.agents;

  supportedAgents = [ "qemu" "glpi" ];
in
{
  options.modules.system.server.communication.agents = lib.mkOption {
    type = lib.types.listOf (lib.types.enum supportedAgents);
    default = [];
    description = ''
      List of agents systems to enable.
      Available options: ${lib.concatStringsSep ", " supportedAgents}
    '';
  };

  config = {
    services = {
      qemuGuest.enable = lib.mkIf (lib.elem "qemu" cfg) true;
      spice-vdagentd.enable = lib.mkIf (lib.elem "qemu" cfg) true;
      glpiAgent.enable = lib.mkIf (lib.elem "glpi" cfg) true;
      fusionInventory.enable = lib.mkIf (lib.elem "glpi" cfg) true;
    };
  };
}
