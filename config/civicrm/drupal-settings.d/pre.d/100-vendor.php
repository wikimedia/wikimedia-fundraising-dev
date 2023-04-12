<?php

global $civibuild;
// This should confirm it is our local devs....
if ($civibuild['WEB_ROOT'] === '/srv/civi-sites/wmff') {
  require_once '/srv/civi-sites/wmff/vendor/autoload.php';
}
