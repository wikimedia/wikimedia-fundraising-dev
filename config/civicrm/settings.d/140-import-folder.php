<?php
global $civibuild;
// This should confirm it is our local devs....
if ($civibuild['WEB_ROOT'] === '/srv/civi-sites/wmff') {
  if (!defined('IMPORT_EXTENSIONS_UPLOAD_FOLDER')) {
    define('IMPORT_EXTENSIONS_UPLOAD_FOLDER', '/srv/civi-sites/wmff/drupal/sites/default/civicrm/extensions/wmf-civicrm/tests/data');
  }
}