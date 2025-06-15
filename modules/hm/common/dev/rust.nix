{ pkgs, lib, config, ... }:

let
  cfg = config.modules.hm.dev.rust;

  rustDefaultPackages = with pkgs; [rustc cargo rust-analyzer clippy rustfmt];

  rustPackages = rustDefaultPackages ++ (map (pkgName: pkgs.${pkgName}) cfg.extraPackages);

in
{
  options.modules.hm.dev.rust = {
    enable = lib.mkEnableOption "Enable Rust development environment";
    extraPackages = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = [];
      description = "Additional rust packages to install; need to specify {name of package}";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = rustPackages;
  };
}
