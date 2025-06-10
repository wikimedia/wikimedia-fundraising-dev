<?php

global $civibuild;
// This should confirm it is our local devs....
if ($civibuild['WEB_ROOT'] === '/srv/civi-sites/wmf') {
  require_once '/srv/civi-sites/wmf/vendor/autoload.php';
}
