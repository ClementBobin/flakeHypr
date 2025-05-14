{ pkgs, config, lib, ... }:

let
  cfg = config.modules.hardware.gpu.amd;
in
{
  options.modules.hardware.gpu.amd = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable amd tools";
    };
  };

  config = lib.mkIf cfg.enable {

    environment.systemPackages = (with pkgs; [
      vulkan-tools
    ]);
  };
}
