{ pkgs, lib, config, ... }:

let
  cfg = config.modules.common.dev.rust;

  rustDefaultPackages = ["rustc" "cargo" "rust-analyzer" "clippy" "rustfmt"];

  rustPackages = (map (v: pkgs."${v}") rustDefaultPackages) ++ (map (pkgName: pkgs.${pkgName}) cfg.extraPackages);

in
{
  options.modules.common.dev.rust = {
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
