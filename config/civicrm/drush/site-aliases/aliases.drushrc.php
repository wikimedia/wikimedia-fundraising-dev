<?php
$aliases['wmff'] = [
  'root' => '/srv/civi-sites/wmff/drupal',
  'uri' => 'https://wmff.localhost:32353/',
  'user' => 1,
  '#env-vars' => [
    // IDE call back - if you call your deployment config
    // wmff in phpstorm this will connect to it
    // when using drush.
    'PHP_IDE_CONFIG' => 'serverName=wmff',
  ],
];
$aliases['dmaster'] = [
  'root' => '/srv/civi-sites/dmaster/web',
  'uri' => 'https://dmaster.localhost:32353/',
  '#env-vars' => [
    // IDE call back - if you call your deployment config
    // dmaster in phpstorm this will connect to it
    // when using drush.
    'PHP_IDE_CONFIG' => 'serverName=dmaster',
  ],
];