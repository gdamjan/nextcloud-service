<?php
$CONFIG = array (
  'datadirectory' => '/var/lib/nextcloud/data',
  'logfile' => '/var/log/nextcloud/nextcloud.log',
  'memcache.local' => '\\OC\\Memcache\\APCu',
  'apps_paths' => [
    [
      'path'=> '/srv/nextcloud/apps',
      'url' => '/apps',
      'writable' => false,
    ],
    [
      'path'=> '/var/lib/nextcloud/apps',
      'url' => '/wapps',
      'writable' => true,
    ],
  ],
);
