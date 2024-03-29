{ pkgs, nextcloud, php, uwsgi, withSystemd ? true }:
let

  apps = [ nextcloud.packages.apps.spreed ];

  phpWithModules = (php.override {
    embedSupport = true;
    cliSupport = true;
    cgiSupport = false;
    fpmSupport = false;
    phpdbgSupport = false;
    systemdSupport = false;
    apxs2Support = false;
  }).buildEnv {
    extensions = { all, ... }:
      with all; [
        sqlite3
        pdo_sqlite
        mysqli
        mysqlnd
        pdo
        pdo_mysql
        ctype
        curl
        dom
        gd
        filter
        intl
        iconv
        mbstring
        openssl
        opcache
        bcmath
        gmp
        imagick
        fileinfo
        pcntl
        posix
        session
        zip
        zlib
        bz2
        redis
        xmlreader
        xmlwriter
        simplexml
        apcu
        sysvsem
        exif
      ];
    extraConfig = ''
      memory_limit=1024M
      apc.enable_cli=1
    '';
  };

  uwsgiWithPhp = uwsgi.override {
    withPAM = false;
    systemd = pkgs.systemdMinimal;
    plugins = [ "php" ];
    php = phpWithModules;
    inherit withSystemd;
  };

  uwsgiConfig = pkgs.substituteAll {
    name = "uwsgi.nextcloud.ini";
    src = ./files/uwsgi.nextcloud.ini.in;
    mimeTypes = "${pkgs.mime-types}/etc/mime.types";
    uwsgiLogger = if withSystemd then "systemd" else "stdio";
    siteRoot = nextcloud;
  };

  nextcloud-service = pkgs.substituteAll {
    name = "nextcloud-uwsgi.service";
    src = ./files/nextcloud-uwsgi.service.in;
    execStart = "${uwsgiWithPhp}/bin/uwsgi --ini ${uwsgiConfig}";
  };

  nextcloud-cron-service = pkgs.substituteAll {
    name = "nextcloud-cron.service";
    src = ./files/nextcloud-cron.service.in;
    php = phpWithModules;
    inherit nextcloud;
  };

  nextcloud-first-run-service = pkgs.substituteAll {
    name = "nextcloud-first-run.service";
    src = ./files/nextcloud-first-run.service.in;
    portableConfig = ./files/portable.config.php;
    php = phpWithModules;
    inherit nextcloud;
    inherit (pkgs) coreutils;
  };

  nextcloud-socket =
    pkgs.concatText "nextcloud-uwsgi.socket" [ ./files/nextcloud-uwsgi.socket ];
  nextcloud-cron-timer =
    pkgs.concatText "nextcloud-cron.timer" [ ./files/nextcloud-cron.timer ];

  occ = pkgs.writeShellScript "occ" ''
    export NEXTCLOUD_CONFIG_DIR=$STATE_DIRECTORY/config/
    ${phpWithModules}/bin/php ${nextcloud}/occ "$@"
  '';

in pkgs.portableService {
  pname = nextcloud.pname;
  version = nextcloud.version;
  description =
    ''Portable "Nextcloud" service run by uwsgi-php and built with Nix'';
  homepage = "https://github.com/gdamjan/nextcloud-service/";

  units = [
    nextcloud-service
    nextcloud-cron-service
    nextcloud-first-run-service
    nextcloud-socket
    nextcloud-cron-timer
  ];

  symlinks = [
    # FIXME: referenced in `files/portable.config.php` for the non-writable apps_paths
    {
      object = nextcloud;
      symlink = "/srv/nextcloud";
    }
    {
      object = "${pkgs.cacert}/etc/ssl";
      symlink = "/etc/ssl";
    }
    {
      object = "${pkgs.bash}/bin/bash";
      symlink = "/bin/sh";
    }
    {
      object = "${phpWithModules}/bin/php";
      symlink = "/bin/php";
    }
    {
      object = occ;
      symlink = "/bin/occ";
    }
  ];
}
