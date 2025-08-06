<?php

global $civicrm_setting;
// This overrides the file in civicrm-buildkit/app/civicrm.settings.d/100-mail.php to
// send email to mailcatcher. When CIVICRM_MAIL_LOG is defined all email will go to
// that folder

// This sets our WMF mailFactory (in the omnimail extension) to send
// to our local dev mailcatcher - accessible at http://localhost:1080/
// This is used for end of year emails and thank you emails & large donations
if (!defined('CIVICRM_SMTP_HOST')) {
  putenv('CIVICRM_SMTP_HOST=mailcatcher:1025');
}

// Local desktop => Prefer to use Mailhog/Mailcatcher.
if (
	// This looks like local nix-based developer workstation...
	function_exists('posix_getlogin') && !in_array(posix_getlogin(), ['jenkins', 'publisher'])
	// This is a regular web/cli process -- not a phpunit process.
	&& !class_exists('PHPUnit\Framework\TestCase', FALSE) && CIVICRM_UF !== 'UnitTests'
) {
	$civicrm_setting['domain']['mailing_backend'] = [
		'outBound_option' => 0,
		'smtpServer' => 'mailcatcher',
		'smtpPort' => 1025,
		## Tip: By default, PHP-FPM hides env-vars. This has to be exported via php-fpm.conf.
		'smtpAuth' => FALSE,
	];
}
