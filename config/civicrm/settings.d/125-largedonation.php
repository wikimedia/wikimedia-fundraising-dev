<?php
global $civicrm_setting;
$civicrm_setting['domain']['large_donation_notifications'] = [
	[
		'threshold' => 100,
		'addressee' => 'fooboo@example.com,blah@example.com',
		'financial_types_excluded' => '10'
	],
	[
		'threshold' => 300,
		'addressee' => 'garbar@example.com,zimbim@example.com',
		'financial_types_excluded' => '10'
	],
];
