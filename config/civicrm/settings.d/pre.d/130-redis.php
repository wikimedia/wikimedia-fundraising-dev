<?php

global $civibuild;
// This should confirm it is our local devs....
if ( $civibuild['WEB_ROOT'] === '/srv/civi-sites/wmff' ) {
	define( 'CIVICRM_DB_CACHE_HOST', 'queues' );
	define( 'CIVICRM_DB_CACHE_CLASS', 'Redis' );
}
