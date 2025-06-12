{ pkgs, lib, config, vars, ... }:

let
  cfg = config.modules.dev.flutter;

  # Android SDK configuration
  androidComposition = pkgs.androidenv.composeAndroidPackages {
    buildToolsVersions = cfg.android.buildToolsVersions;
    platformVersions = cfg.android.platformVersions;
    abiVersions = cfg.android.abiVersions;
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

    android = {
      buildToolsVersions = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ "30.0.3" "28.0.3" ];
        description = "List of Android build tools versions to include.";
      };

      platformVersions = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ "31" "28" ];
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
        # TODO: move to its own module
        pkgs.google-chrome
      ]
      ++ lib.optional cfg.withAndroid androidSdk;

    # Environment variables
    environment.variables = lib.mkMerge [
      { JAVA_HOME = "${cfg.jdkPackage}"; }
      { STUDIO_JDK = "${cfg.jdkPackage}"; }
      { CHROME_EXECUTABLE = "${pkgs.google-chrome}/bin/google-chrome-stable"; }
      (lib.mkIf cfg.withAndroid {
        ANDROID_HOME = "${androidSdk}/libexec/android-sdk";
      })
    ];

    programs = {
      adb.enable = true;
    };

    users.users.${vars.user} = {
      extraGroups = [
        "adbusers"
      ];
    };

    # Shell profile additions
    environment.shellInit = ''
      export PATH="$JAVA_HOME/bin:$PATH"
      ${lib.optionalString cfg.withAndroid ''
      export PATH="$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/emulator:$ANDROID_HOME/platform-tools:$PATH"
      ''}
    '';
  };
}