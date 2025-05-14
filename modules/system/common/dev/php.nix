{ pkgs, lib, config, ... }:

let
  cfg = config.modules.dev.php;
in
{
  options.modules.dev.php = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable php development environment";
    };

    installMethod = lib.mkOption {
      type = lib.types.enum [ "hm" "sys" ];
      default = "sys";
      description = "Choose whether to install php via home-manager or directly in the environment.";
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = lib.mkIf (cfg.installMethod == "sys") (with pkgs; [
      php83Extensions.xdebug
      php83Extensions.sqlsrv
      php83
      php83Packages.composer
    ]);

    # Optionally, configure HTTPD with PHP support
        services.httpd.phpPackage = pkgs.php.buildEnv {
            extensions = ({ enabled, all }: enabled ++ (with all; [
                xdebug
                sqlsrv
                pdo_sqlsrv
            ]));
            extraConfig = ''
            [PHP]
            [Syslog]
            define_syslog_variables=Off
            [Session]
            define_syslog_variables=Off
            [Date]
            date.timezone=Europe/Berlin
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
            zend_extension=xdebug
            xdebug.mode=debug
            xdebug.start_with_request=yes
            extension=sqlsrv
            extension=pdo_sqlsrv
            '';
        };
  };
}
