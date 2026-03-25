{ pkgs, lib, config, ... }:
let
  cfg = config.modules.hm.dev.languages.php;

  # Build PHP environment with selected extensions and config
  phpWithExtensions = version: let
    phpAttr = "php${version}";
    phpPkg = pkgs.${phpAttr};
    phpExtsAttr = "${phpAttr}Extensions";
    phpExts = pkgs.${phpExtsAttr};
    phpPkgsAttr = "${phpAttr}Packages";
    phpPkgs = pkgs.${phpPkgsAttr};

    # Map extra extension names to actual derivations
    extraExtsMapped = map (ext: phpExts.${ext}) cfg.extraExtensions;
  in
    phpPkg.buildEnv {
      extensions = ({ enabled, all }: enabled ++ extraExtsMapped ++ (with all; [
        xdebug
      ] ++ lib.optionals cfg.mssql.enable [
        sqlsrv
        pdo_sqlsrv
      ]));
      extraConfig = cfg.extraConfig + lib.optionalString cfg.xdebug.enable ''
        zend_extension=xdebug
        xdebug.mode=${cfg.xdebug.mode}
        xdebug.start_with_request=${if cfg.xdebug.startWithRequest then "yes" else "no"}
      '' + lib.optionalString cfg.mssql.enable ''
        extension=sqlsrv
        extension=pdo_sqlsrv
      '';
    };

  selectedPhp = phpWithExtensions cfg.version;

in {
  options.modules.hm.dev.languages.php = {
    enable = lib.mkEnableOption "Enable PHP development environment";

    version = lib.mkOption {
      type = lib.types.str;
      default = "83";
      description = "PHP version to install (e.g. '83' for php83)";
    };

    extraExtensions = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
      description = ''Extra PHP extensions to install (e.g., ["redis" "imagick"])'';
    };

    composer.enable = lib.mkEnableOption "Install Composer" // { default = true; };

    xdebug = {
      enable = lib.mkEnableOption "Enable Xdebug" // { default = true; };
      mode = lib.mkOption {
        type = lib.types.str;
        default = "debug";
        description = "Xdebug mode (debug, coverage, profile, trace)";
      };
      startWithRequest = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Whether Xdebug starts with every request";
      };
    };

    mssql = {
      enable = lib.mkEnableOption "Enable MSSQL/sqlsrv extensions";
    };

    timezone = lib.mkOption {
      type = lib.types.str;
      default = "Europe/Berlin";
      description = "PHP date.timezone setting";
    };

    extraConfig = lib.mkOption {
      type = lib.types.lines;
      default = ''
        [PHP]

        [Date]
        date.timezone=${cfg.timezone}

        [MySQL]
        mysql.allow_local_infile=On
        mysql.allow_persistent=On
        mysql.cache_size=2000
        mysql.max_persistent=-1
        mysql.max_link=-1
        mysql.default_port=3306
        mysql.default_socket="MySQL"
        mysql.connect_timeout=3
        mysql.trace_mode=Off

        [Session]
        define_syslog_variables=Off

        [Syslog]
        define_syslog_variables=Off

        [Sybase-CT]
        sybct.allow_persistent=On
        sybct.max_persistent=-1
        sybct.max_links=-1
        sybct.min_server_severity=10
        sybct.min_client_severity=10

        [MSSQL]
        mssql.allow_persistent=On
        mssql.max_persistent=-1
        mssql.max_links=-1
        mssql.min_error_severity=10
        mssql.min_message_severity=10
        mssql.compatibility_mode=Off
        mssql.secure_connection=Off
      '';
      description = "Raw PHP ini configuration to inject";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages =
      [ selectedPhp ]
      ++ lib.optional cfg.composer.enable pkgs."php${cfg.version}Packages".composer;

    home.shellAliases = {
      php = "${selectedPhp}/bin/php";
      composer = lib.mkIf cfg.composer.enable "${pkgs."php${cfg.version}Packages".composer}/bin/composer";
    };
  };
}