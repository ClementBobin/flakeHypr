{ pkgs, lib, config, vars, ... }:

let
  cfg = config.modules.system.dev.languages.flutter;

  # Android SDK configuration
  androidEnv = pkgs.androidenv.override { licenseAccepted = true; };
  androidComposition = androidEnv.composeAndroidPackages {
    buildToolsVersions = cfg.android.buildToolsVersions;
    platformVersions = cfg.android.platformVersions;
    abiVersions = cfg.android.abiVersions;
  };
  androidSdk = androidComposition.androidsdk;
in
{
  options.modules.system.dev.languages.flutter = {
    enable = lib.mkEnableOption "Flutter development environment";

    withAndroid = lib.mkEnableOption "Include Android SDK tooling";

    jdkPackage = lib.mkOption {
      type = lib.types.package;
      default = pkgs.jdk17;
      description = "Java Development Kit package to use for Flutter development";
    };

    android = {
      buildToolsVersions = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ "34.0.0" "28.0.3" ];
        description = "List of Android build tools versions to include.";
      };

      platformVersions = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ "34" "28" ];
        description = "List of Android platform versions to include.";
      };

      abiVersions = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ "armeabi-v7a" "arm64-v8a" ];
        description = "List of Android ABI versions to include.";
      };
    };
  };

  config = lib.mkIf cfg.enable {

    environment.systemPackages =
      [
        pkgs.flutter
        cfg.jdkPackage
      ]
      ++ lib.optional cfg.withAndroid androidSdk;

    # Environment variables
    environment.variables = lib.mkIf cfg.withAndroid {
      ANDROID_HOME = "${androidSdk}/libexec/android-sdk";
    };

    programs = lib.mkIf cfg.withAndroid { adb.enable = true; };

    users.users.${vars.user}.extraGroups = [
      "adbusers"
    ];
  };
}