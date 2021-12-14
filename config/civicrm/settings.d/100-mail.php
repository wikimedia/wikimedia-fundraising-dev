<?php

// This overrides the file in civicrm-buildkit/app/civicrm.settings.d/100-mail.php to
// send email to mailcatcher. When CIVICRM_MAIL_LOG is defined all email will go to
// that folder

// This sets our WMF mailFactory (in the omnimail extension) to send
// to our local dev mailcatcher - accessible at http://localhost:1080/
// This is used for end of year emails and thank you emails & large donations
if (!defined('CIVICRM_SMTP_HOST')) {
  putenv('CIVICRM_SMTP_HOST=mailcatcher:1025');
}
