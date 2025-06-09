<?php

global $civibuild;
// This should confirm it is our local devs....
if (str_starts_with($civibuild['WEB_ROOT'], '/srv/civi-sites/wmf')) {
  require_once '/srv/civi-sites/wmf/vendor/autoload.php';
}
