{ pkgs, config, lib, ... }:

let
  cfg = config.modules.hardware.gpu.amd;
in
{
  options.modules.hardware.gpu.amd = {
    enable = lib.mkEnableOption "Enable AMD GPU support with Vulkan tools";
  };

  config = lib.mkIf cfg.enable {

    environment.systemPackages = (with pkgs; [
      vulkan-tools
    ]);
  };
}
