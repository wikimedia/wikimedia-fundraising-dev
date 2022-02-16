<?php
global $civicrm_setting;
$civicrm_setting['domain']['wmf_email_preferences_url'] = 'https://localhost:' .
	getenv( 'FR_DOCKER_EMAIL_PREF_CTR_PORT' ) . '/index.php?title=Special:EmailPreferences/emailPreferences';
