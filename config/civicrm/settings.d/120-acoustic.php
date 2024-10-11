<?php
if (file_exists('/srv/config/private/civicrm/AcousticCredentials.php')) {
	$civicrm_setting['domain']['omnimail_credentials']['Silverpop'] =
		require '/srv/config/private/civicrm/AcousticCredentials.php';
}
$civicrm_setting['domain']['omnimail_allowed_upload_folders'] = [
	'/tmp/'
];
