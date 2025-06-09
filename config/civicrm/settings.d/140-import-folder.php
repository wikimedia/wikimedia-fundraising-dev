<?php
global $civibuild;
// This should confirm it is our local devs....
if ($civibuild['WEB_ROOT'] === '/srv/civi-sites/wmf') {
  if (!defined('IMPORT_EXTENSIONS_UPLOAD_FOLDER')) {
    define('IMPORT_EXTENSIONS_UPLOAD_FOLDER', '/srv/civi-sites/wmf/drupal/sites/default/civicrm/extensions/wmf-civicrm/tests/data');
  }
}