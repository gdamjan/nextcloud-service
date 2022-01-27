{ pkgs ? import <nixpkgs> {}, withSystemd ? true }:

let
  squash-compression = "xz -Xdict-size 100%";

  nextcloud = (import ./nextcloud.nix { inherit pkgs; });

  php = (pkgs.php.override {
    embedSupport = true;
    cliSupport = true;
    cgiSupport = false;
    fpmSupport = false;
    phpdbgSupport = false;
    systemdSupport = false;
    apxs2Support = false;
  }).withExtensions ({ all, ... }: with all; [
    sqlite3 pdo_sqlite mysqli mysqlnd pdo pdo_mysql ctype curl dom gd filter intl iconv mbstring openssl opcache
    bcmath gmp imagick fileinfo pcntl posix session zip zlib bz2 redis xmlreader xmlwriter simplexml apcu
  ]);

  uwsgiConfig = pkgs.substituteAll {
    name = "uwsgi.nextcloud.ini";
    src = ./files/uwsgi.nextcloud.ini.in;
    mimeTypes = pkgs.mime-types + "/etc/mime.types";
    uwsgiLogger = if withSystemd then "systemd" else "stdio";
    inherit nextcloud php withSystemd;
  };

  uwsgi = pkgs.uwsgi.override {
    systemd = pkgs.systemdMinimal;
    withPAM = false;
    withSystemd = withSystemd;
    plugins = ["php"];
    php = php;
  };

  rootfs = pkgs.stdenv.mkDerivation rec {
    name = "rootfs";
    inherit uwsgi php nextcloud uwsgiConfig;
    coreutils = pkgs.coreutils;
    nextcloudConfig = ./files/nextcloud.config.php;

    buildCommand = ''
        # prepare the portable service file-system layout
        mkdir -p $out/etc/systemd/system $out/proc $out/sys $out/dev $out/run $out/tmp $out/var/tmp $out/usr/bin
        touch $out/etc/resolv.conf $out/etc/machine-id
        cp ${./files/os-release} $out/etc/os-release
        ln -s ${pkgs.bash}/bin/bash $out/usr/bin/sh
        ln -s ${php}/bin/php $out/usr/bin/php
        ln -s usr/bin $out/bin

        mkdir -p $out/srv
        ln -s ${nextcloud} $out/srv/nextcloud

        # create empty directories as mount points for the services
        mkdir -p $out/var/lib/nextcloud $out/var/log/nextcloud $out/etc/ssl/certs
        substituteAll ${./files/nextcloud.service.in} $out/etc/systemd/system/nextcloud.service
        substituteAll ${./files/nextcloud-cron.service.in} $out/etc/systemd/system/nextcloud-cron.service
        substituteAll ${./files/nextcloud-first-run.service.in} $out/etc/systemd/system/nextcloud-first-run.service
        cp ${./files/nextcloud.socket} $out/etc/systemd/system/nextcloud.socket
        cp ${./files/nextcloud-cron.timer} $out/etc/systemd/system/nextcloud-cron.timer
    '';
  };

in

pkgs.stdenv.mkDerivation {
  name = "nextcloud.raw";
  nativeBuildInputs = [ pkgs.squashfsTools ];

  buildCommand = ''
      closureInfo=${pkgs.closureInfo { rootPaths = [ rootfs ]; }}

      mkdir -p nix/store
      for i in $(< $closureInfo/store-paths); do
        cp -a "$i" "''${i:1}"
      done

      # archive the nix store
      mksquashfs nix ${rootfs}/* $out \
        -noappend \
        -keep-as-directory \
        -all-root -root-mode 755 \
        -b 1048576 -comp ${squash-compression}
  '';
}
