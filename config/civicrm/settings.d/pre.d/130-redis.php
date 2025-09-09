<?php

global $civibuild;
// This should confirm it is our local devs....
if (str_starts_with($civibuild['WEB_ROOT'], '/srv/civi-sites/wmf')) {
  define('CIVICRM_DB_CACHE_HOST', 'queues');
  define('CIVICRM_DB_CACHE_CLASS', 'Redis');
  ini_set('session.save_handler', 'redis');
}
