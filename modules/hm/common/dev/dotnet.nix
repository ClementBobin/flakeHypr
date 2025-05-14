{ pkgs, lib, config, ... }:

let
  cfg = config.modules.common.dev.dotnet;
in
{
  options.modules.common.dev.dotnet = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable dotnet development environment";
    };

    installMethod = lib.mkOption {
      type = lib.types.enum [ "hm" "sys" ];
      default = "hm";
      description = "Choose whether to install dotnet via home-manager or directly in the environment.";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = lib.mkIf (cfg.installMethod == "hm") (with pkgs; [
      dotnet-sdk_8
    ]);
  };
}
