{ pkgs, lib, config, ... }:

let
  cfg = config.modules.dev.flutter;

  # Android SDK configuration
  buildToolsVersion = "30.0.3";
  androidComposition = pkgs.androidenv.composeAndroidPackages {
    buildToolsVersions = [ buildToolsVersion "28.0.3" ];
    platformVersions = [ "31" "28" ];
    abiVersions = [ "armeabi-v7a" "arm64-v8a" ];
  };
  androidSdk = androidComposition.androidsdk;
in
{
  options.modules.dev.flutter = {
    enable = lib.mkEnableOption "Flutter development environment";

    withAndroid = lib.mkEnableOption "Include Android SDK tooling";

    jdkPackage = lib.mkOption {
      type = lib.types.package;
      default = pkgs.jdk17;
      description = "Java Development Kit package to use for Flutter development";
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages =
      [ pkgs.flutter cfg.jdkPackage ]
      ++ lib.optional cfg.withAndroid androidSdk;

    # Environment variables
    environment.variables = lib.mkMerge [
      { JAVA_HOME = "${cfg.jdkPackage}"; }
      (lib.mkIf cfg.withAndroid {
        ANDROID_HOME = "${androidSdk}/libexec/android-sdk";
      })
    ];

    # Shell profile additions
    environment.shellInit = ''
      export PATH="$JAVA_HOME/bin:$PATH"
      ${lib.optionalString cfg.withAndroid ''
        export PATH="$ANDROID_HOME/tools/bin:$ANDROID_HOME/platform-tools:$PATH"
      ''}
    '';
  };
}