<?php
# Nextcloud supports multiple config files, that override the generated config.php
# Here we specify the configuration that's specific when running in a portable
# service.
# https://docs.nextcloud.com/server/stable/admin_manual/configuration_server/config_sample_php_parameters.html#multiple-config-php-file
$STATE_DIRECTORY = explode(":", $_ENV["STATE_DIRECTORY"])[0];
$LOGS_DIRECTORY = explode(":", $_ENV["LOGS_DIRECTORY"])[0];
$CONFIG = array (
  'datadirectory' =>  $STATE_DIRECTORY . '/data',
  'logfile' => $LOGS_DIRECTORY . '/nextcloud.log',
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
