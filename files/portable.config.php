<?php
# Nextcloud supports multiple config files, that override the generated config.php
# https://docs.nextcloud.com/server/stable/admin_manual/configuration_server/config_sample_php_parameters.html#multiple-config-php-file
#
# Here we specify the configuration that's specific when running in a portable
# service.
# - use systemd STATE_DIRECTORY and LOGS_DIRECTORY env variables to set
#   datadirectory and logfile locations
# - setup 2 readable and 1 writable apps directory:
#   one for the apps that ship with nextcloud
#   one for any additional apps in this package
#   and last a writable path inside STATE_DIRECTORY for apps installed from the
#   store by the admin

$STATE_DIRECTORY = explode(":", getenv("STATE_DIRECTORY"))[0];
$LOGS_DIRECTORY = explode(":", getenv("LOGS_DIRECTORY"))[0];

$CONFIG = array (
  'datadirectory' => $STATE_DIRECTORY . '/data',
  'logfile'       => $LOGS_DIRECTORY . '/nextcloud.log',
  'memcache.local' => '\\OC\\Memcache\\APCu',
  'apps_paths' => [
    [
      'path'=> '/srv/nextcloud/apps',
      'url' => '/apps',
      'writable' => false,
    ],
    [
      'path'=> $STATE_DIRECTORY . '/apps',
      'url' => '/wapps',
      'writable' => true,
    ],
  ],
);
