<?php
# This file should be required by LocalSettings.php for the Fundraising development setup.

#############################################################################
### Begin settings generated by maintenance/install.php                   ###
### A few of these settings have been tweaked manually, but the original  ###
### structure and comments are left intact.                               ###
#############################################################################

# See includes/DefaultSettings.php for all configurable settings
# and their default values, but don't forget to make changes in _this_
# file, not there.
#
# Further documentation for configuration settings may be found at:
# https://www.mediawiki.org/wiki/Manual:Configuration_settings

# Protect against web entry
if ( !defined( 'MEDIAWIKI' ) ) {
	exit;
}

## Uncomment this to disable output compression
# $wgDisableOutputCompression = true;

$wgSitename = "Payments";

## The URL base path to the directory containing the wiki;
## defaults for all runtime URL paths are based off of this.
## For more information on customizing the URLs
## (like /w/index.php/Page_title to /wiki/Page_title) please see:
## https://www.mediawiki.org/wiki/Manual:Short_URL
$wgScriptPath = "";

if ( substr( $_SERVER['SERVER_NAME'], 0, 12) === 'paymentstest' ) {
	$_SERVER['REQUEST_SCHEME'] = 'https';
	$_SERVER['HTTP_X_FORWARDED_PROTO'] = 'https';
}
## The protocol and server name to use in fully-qualified URLs
$wgServer = WebRequest::detectServer();

## The URL path to static resources (images, scripts, etc.)
$wgResourceBasePath = $wgScriptPath;

## UPO means: this is also a user preference option

$wgEnableEmail = true;
$wgEnableUserEmail = true; # UPO

$wgEmergencyContact = "fr-tech@wikimedia.org"; ### tweaked from auto-generated settings
$wgPasswordSender = "fr-tech@wikimedia.org"; ### tweaked from auto-generated settings

$wgEnotifUserTalk = false; # UPO
$wgEnotifWatchlist = false; # UPO
$wgEmailAuthentication = true;

## Database settings
$wgDBtype = "mysql";
$wgDBserver = "database";
$wgDBname = "payments";
$wgDBuser = "root";
$wgDBpassword = "";

# MySQL specific settings
$wgDBprefix = "";

# MySQL table options to use during installation or update
$wgDBTableOptions = "ENGINE=InnoDB, DEFAULT CHARSET=binary";

## Shared memory settings
$wgMainCacheType = CACHE_ACCEL;
# $wgMemCachedServers = []; ### Auto-generated file sets this to an empty array. We set it below.

## To enable image uploads, make sure the 'images' directory
## is writable, then set this to true:
$wgEnableUploads = false;
#$wgUseImageMagick = true;
#$wgImageMagickConvertCommand = "/usr/bin/convert";

# InstantCommons allows wiki to use images from https://commons.wikimedia.org
$wgUseInstantCommons = false;

# Periodically send a pingback to https://www.mediawiki.org/ with basic data
# about this MediaWiki instance. The Wikimedia Foundation shares this data
# with MediaWiki developers to help guide future development efforts.
$wgPingback = false;

## If you use ImageMagick (or any other shell command) on a
## Linux server, this will need to be set to the name of an
## available UTF-8 locale
$wgShellLocale = "C.UTF-8";

## Set $wgCacheDirectory to a writable directory on the web server
## to make your wiki go slightly faster. The directory should not
## be publicly accessible from the web.
##
#### Note for fundraising-dev repo: This is set further down.
#$wgCacheDirectory = "$IP/cache";

# Site language code, should be one of the list in ./languages/data/Names.php
$wgLanguageCode = "en";

$wgSecretKey = "90bbdcbb8c8340c02e73eecfe1decedd597a7764193c67f4914424ac976d0930";
# Changing this will log out all existing sessions.
$wgAuthenticationTokenVersion = "1";

# Site upgrade key. Must be set to a string (default provided) to turn on the
# web installer while LocalSettings.php is in place
$wgUpgradeKey = "20f659bc4f801f3e";

$wgCookieSameSite = "none";
$wgCookieSecure = true;

## For attaching licensing metadata to pages, and displaying an
## appropriate copyright notice / icon. GNU Free Documentation
## License and Creative Commons licenses are supported so far.
$wgRightsPage = ""; # Set to the title of a wiki page that describes your license/copyright
$wgRightsUrl = "";
$wgRightsText = "";
$wgRightsIcon = "";

# Path to the GNU diff3 utility. Used for conflict resolution.
$wgDiff3 = "/usr/bin/diff3";

## Default skin: you can change the default skin. Use the internal symbolic
## names, ie 'vector', 'monobook':
$wgDefaultSkin = "vector";

# Enabled skins.
# The following skins were automatically enabled:
wfLoadSkin( 'Vector' );

# End of automatically generated settings.
# Add more configuration options below.

##########################################################
### End settings generated by maintenance/install.php  ###
##########################################################

# TODO Check whether the settings included in DevelopmentSettings.php
# are appropriate, especially as regards logging, and maybe enable this:
# require_once "$IP/includes/DevelopmentSettings.php";

##########################################################
### Begin payments-specific general Mediawiki settings ###
##########################################################

# Prevent server- and client-side caching of page content
$wgParserCacheType = CACHE_NONE;
$wgCachePages = false;
$wgUseFileCache = false;

### Settings below are based on settings for staging in the localsettings repo,
### at commit c6a5b1dac95876199.

# TODO Check all these, too.

# $wgUseFileCache and $wgFileCacheDirectory omitted here; see above
$wgCacheDirectory = '/tmp/'; # Different value from staging
$wgLocalisationUpdateDirectory = "{$wgCacheDirectory}/l10n";

# NoLogin
function NoLoginLinkOnMainPage($skinTemplate, &$links){
	unset($links['user-menu']['login-private']);
	$skinTemplate->userpageUrlDetails = [];
}
$wgHooks['SkinTemplateNavigation::Universal'][]='NoLoginLinkOnMainPage';
$wgHooks['AlterPaymentFormData'][] = 'EndowmentHooks::onAlterPaymentFormData';
$wgHooks['BeforePageDisplay'][] = 'EndowmentHooks::onBeforePageDisplay';

### (Profiling settings, below, are enabled on staging. Commenting them out for now.)
# TODO Set up profiling in Docker?
# Profiling
# wgProfiling = false;
# $wgProfileSampleRate = 1;
# //$wgProfilerType = 'SimpleUDP';
# /** Only record profiling info for pages that took longer than this */
# $wgProfileLimit = 0.0;
# /** Don't put non-profiling info into log file */
# $wgProfileOnly = false;
# /** Log sums from profiling into "profiling" table in db. */
# $wgProfileToDatabase = false;
# /** If true, print a raw call tree instead of per-function report */
# $wgProfileCallTree = false;
# /** Should application server host be put into profiling table */
# $wgProfilePerHost = false;
#
# /** Settings for UDP profiler */
# $wgUDPProfilerHost = '10.0.0.25';
# $wgUDPProfilerPort = '3811';
#
# /** Detects non-matching wfProfileIn/wfProfileOut calls */
# $wgDebugProfiling = false;
# /** Output debug message on every wfProfileIn/wfProfileOut */
# $wgDebugFunctionEntry = 0;
# /** Lots of debugging output from SquidUpdate.php */
# $wgDebugSquid = false;

# TODO Move this elsewhere
# If PHP's memory limit is very low, some operations may fail.
ini_set( 'memory_limit', '256M' );

# TODO Maybe move this elsewhere, too
if ( $wgCommandLineMode ) {
	if ( isset( $_SERVER ) && array_key_exists( 'REQUEST_METHOD', $_SERVER ) ) {
		die( "This script must be run from the command line\n" );
	}
}

### Logging setup
# See https://phabricator.wikimedia.org/T107918 for initial discussion of this setup
$defaultProcessors = array(
	'wiki' => array(
		'class' => 'MediaWiki\Logger\Monolog\WikiProcessor',
	),
	'psr' => array(
		'class' => 'Monolog\Processor\PsrLogMessageProcessor',
	),
	'pid' => array(
		'class' => 'Monolog\Processor\ProcessIdProcessor',
	),
	'uid' => array(
		'class' => 'Monolog\Processor\UidProcessor',
	),
	'web' => array(
		'class' => 'Monolog\Processor\WebProcessor',
	),
);

$syslogLogger = array(
	'handlers' => array( 'syslog' ),
	'processors' => array_keys( $defaultProcessors ),
);

$wgMWLoggerDefaultSpi = array(
	'class' => 'MediaWiki\Logger\MonologSpi',
	'args' => array( array(
		'formatters' => array(
			'line' => array(
				'class' => 'Monolog\Formatter\LineFormatter',
				'args' => array( 'mediawiki[%extra.process_id%]: %message%' ),
			),
		),
		'handlers' => array(
			'syslog' => array(
				'class' => 'MediaWiki\Logger\Monolog\SyslogHandler',
				'args' => array(
					'mediawiki',
					# Sending to external logger since local syslog only listens on
					# socket
					getenv( "FR_DOCKER_LOGGER_HOST" ),
					9514,
					LOG_USER,
					# For extremely verbose MW logs, set this to DEBUG
					Monolog\Logger::INFO,
				),
				'formatter' => 'line',
			),
		),
		'loggers' => array(
			'@default' => $syslogLogger,
		),
		'processors' => $defaultProcessors,
	), ),
);

### Debug and log settings
# TODO Make sure we get whatever would go in the file set by wgDBerrorLog.
$wgDevelopmentWarnings = true;
$wgShowExceptionDetails = true;
$wgShowHostnames = true;
$wgDebugRawPage = true;

### This line is Docker-specific. On staging, we set this using $hwgMemCachedServers,
### which in turn is set in /etc/LocalSettings.php. Also, note that the empty value for
### $wgMemCachedServers auto-generated by Mediawiki's install.php is commented out in the
### section from that script, above.
$wgMemCachedServers = [ 'memcached:11211' ];

$wgSessionsInObjectCache = true;
$wgSessionCacheType = CACHE_MEMCACHED;

# Commenting out this line from staging config, since it's probably not what
# we want.
# $wgObjectCacheSessionExpiry = 24 * 60 * 60;

$wgRawHtml = true;

# When you make changes to this configuration file, this will make
# sure that cached pages are cleared.
$wgCacheEpoch = max( $wgCacheEpoch, gmdate( 'YmdHis', @filemtime( __FILE__ ) ) );

$wgLogos = [
	"1x" => "/images/e/eb/Wmf_logo.png",
	"1.5x" => "/images/f/fc/Wmf_logo_1.5x.png",
	"2x" => "/images/d/d1/Wmf_logo_2x.png"
];

$wgGroupPermissions['*']['createaccount'] = false;
$wgGroupPermissions['*']['edit'] = false;
$wgGroupPermissions['*']['read'] = false;
$wgGroupPermissions['user']['edit'] = false;
$wgGroupPermissions['sysop']['edit'] = false;
$wgGroupPermissions['sysop']['edit'] = true;
$wgWhitelistRead =  array (
	"Special:GlobalCollectGatewayResult",
	"Special:GlobalCollectGateway",
	"2010_Landing_9/en",
	"-",
	"MediaWiki:Common.css",
	"MediaWiki:Print.css",
	"MediaWiki:Vector.css",
	"Donate-error",
	"Special:GatewayChooser",
	"Special:GatewayFormChooser", // Legacy, but let's leave this here to mirror expected prod settings.
	"Special:AmazonGateway",
	"Special:FundraiserMaintenance",
	"Special:FundraiserUnsubscribe",
	"Special:FundraiserSubscribe",
	"Special:OptIn",
	"Special:EmailPreferences",
	"Special:SystemStatus",
	"Special:BraintreeGateway",
	"Special:BraintreeGatewayResult",
	"Special:PaypalExpressGateway",
	"Special:PaypalExpressGatewayResult",
	"Special:PaypalLegacyGateway",
	"Special:AdyenCheckoutGateway",
	"Special:AdyenCheckoutGatewayResult",
	"Special:AstroPayGateway",
	"Special:AstroPayGatewayResult",
	"Special:IngenicoGatewayResult",
	"Special:IngenicoGateway",
	"Special:DlocalGateway",
	"Special:DlocalGatewayResult",
	"Main_Page",
	"Donate-thanks"
);

$wgBlockDisablesLogin = true;

$wgAllowUserCss = false;

wfLoadExtensions( array(
	'cldr',
	'ParserFunctions',
	'DonationInterface',
	'FundraisingEmailUnsubscribe',
	'WikiEditor',
	'SyntaxHighlight_GeSHi'
) );

# TODO Commenting out for now, since this doesn't seem useful for dev setup.
#$wgUseCdn = true;
#$wgCdnServers = array('127.0.0.1');

###################################################
### Begin public settings for DonationInterface ###
###################################################

### These settings configure payment processors supported by DonationInterface.
### They are mostly based on settings from staging at localsettings commit c6a5b1dac95876199,
### vagrant puppet/modules/payments/manifests/donation_interface.pp at commit
### 2fdf07cd5ade16 and the 2017-05-31 version of
### https://www.mediawiki.org/wiki/Fundraising_tech/donation_pipeline_setup/settings#Payments-Wiki_LocalSettings.php.
###
### Note that many settings in staging have been moved to the private repository
### instead of here. Below are just the settings that have been left public.
###
### Inline comments have been added about minor differences with staging
### or vagrant settings.

# TODO Check all these settings

# Set as per production LocalSettings.php
$wgHooks['AlterPaymentFormData'][] = 'EndowmentHooks::onAlterPaymentFormData';

# Queues
$fundraisingEmailUnsubscribeQueueDefaults = array(
	'servers' => array(
		'scheme' => 'tcp',
		'host' => 'queues',
		'port' => 6379,
	),
);

$wgFundraisingEmailUnsubscribeQueueClass = 'PHPQueue\Backend\Predis';
$wgFundraisingEmailUnsubscribeQueueParameters = array(
	'unsubscribe' => $fundraisingEmailUnsubscribeQueueDefaults,
	'opt-in' => $fundraisingEmailUnsubscribeQueueDefaults,
);

# Gateways
$wgAdyenCheckoutGatewayEnabled = true;
$wgAmazonGatewayEnabled = true;
$wgAstroPayGatewayEnabled = true;
$wgDlocalGatewayEnabled = true;
$wgGlobalCollectGatewayEnabled = true;
$wgIngenicoGatewayEnabled = true;
$wgBraintreeGatewayEnabled = true;
$wgPaypalExpressGatewayEnabled = true;

# Components
$wgDonationInterfaceEnableReferrerFilter = true;
$wgDonationInterfaceEnableSourceFilter = true;
$wgDonationInterfaceEnableFunctionsFilter = true;
$wgDonationInterfaceEnableConversionLog = true;

# The setting below is enabled on staging, but it's best to leave it off for dev setup
$wgDonationInterfaceEnableIPVelocityFilter = false;

$wgDonationInterfaceEnableGatewayChooser = true;
$wgDonationInterfaceEnableSessionVelocityFilter = false;
$wgDonationInterfaceEnableSystemStatus = true;
$wgDonationInterfaceEnableBannerHistoryLog = true;

# As per vagrant, leaving this off, though it's on for staging. Also not setting
# $wgDonationInterfaceMinFraudWeight, which is set on staging. See private
# settings for related stuff. TODO Check this.
$wgDonationInterfaceEnableMinFraud = false;

$wgDonationInterfaceThankYouPage = 'https://thankyou.wikipedia.org/wiki/Thank_You';
$wgDonationInterfacePriceCeiling = 12000;

# Value on staging: 'http://wikimediafoundation.org/wiki/DonateNonJS/en'
$wgDonationInterfaceNoScriptRedirect = 'http://testNoScriptRedirect.example.com/blah';

$wgDonationInterfaceUseSyslog = true;
$wgDonationInterfaceSaveCommStats = true;
$wgDonationInterfaceTimeout = 12; # Comment from staging: Can't seem to override this for PayPal EC, trying here in desperation

$wgIngenicoGatewayHostedFormVariants = [ 'iframe' => 102, 'redirect' => 101 ];

# Always notify donor when we automatically switch currency.
$wgDonationInterfaceNotifyOnConvert = true;

### Set form_variants directory. This value is specific to our Docker setup. The setting
### is also on vagrant and staging, with different values.
$wgDonationInterfaceVariantConfigurationDirectory =
	'/var/www/html/extensions/DonationInterface/form_variants';

# Directory for files to override shipped defaults in yaml config files.
$wgDonationInterfaceLocalConfigurationDirectory = '/srv/config/exposed/payments/di-config';

# ZOMG DIRE EMERGENCY aka shut down gracefully :p
# $wgDonationInterfaceFundraiserMaintenance = true;

# Always ask for monthly donation after one-time in these countries, even when
# no variant is specified on the querystring.
$wgDonationInterfaceMonthlyConvertCountries = [
  'AT',
  'AU',
  'BE',
  'CA',
  'CZ',
  'ES',
  'FR',
  'GB',
  'IE',
  'IT',
  'JP',
  'LU',
  'NL',
  'NZ',
  'SE',
  'US'
];

$wgDonationInterfaceMonthlyConvertAmounts = [
	"BRL" => [
		[ 15, 0 ],
		[ 25000, 10 ]
	],
	"MXN" => [
		[ 30, 0 ],
		[ 25000, 20 ]
	],
	"ARS" => [
		[ 190, 0 ],
		[ 25000, 185 ]
	],
	"CLP" => [
		[ 900, 0 ],
		[ 25000, 850 ]
	],
	"COP" => [
		[ 5000, 0 ],
		[ 25000, 4900 ]
	],
	"PEN" => [
		[ 15, 0 ],
		[ 25000, 10 ]
	],
	"UYU" => [
		[ 49, 0 ],
		[ 25000, 40 ]
	]
];

# These debug and log settings are scattered in various parts of staging LocalSettings.php.
# Moving them to the bottom of this file for easier tweaking.

# Enabled in vagrant but not on staging
# TODO Check if this should be on. README.txt says, "Test mode flag,
# alters various behavior."
$wgDonationInterfaceTest = false;
$wgDonationInterfaceTestMode = false;

# Note: Several other "Test" settings were set in the private 20-DI-accounts.php file, and
# have been left private in config-private/payments/LocalSettings-private.php, just in case
# they need to be there.
# They are: $wgAstroPayGatewayTest, $wgGlobalCollectGatewayTest,
# and $wgAmazonGatewayTest (different from above). TODO Check this, and maybe
# move those settings here.

# The following settings only appear in the mediawiki.org documentation.
$wgAmazonGatewayTestMode = true;
$wgDonationInterfaceFailPage = 'Donate-error';
$wgDonationInterfaceLogCompleted = true;

# Set this to false for less verbose logging
$wgDonationInterfaceLogDebug = true;
$wgIngenicoGatewayCurlVerboseLog = true;
$wgAstroPayGatewayCurlVerboseLog = true;
$wgDonationInterfaceEmployersListDataFileLocation = '/srv/config/private/payments/employerData.csv';

### Include private settings
require( '/srv/config/private/payments/LocalSettings-private.php' );

### Include optional settings not tracked by git
if ( file_exists ( '/srv/config/exposed/payments/LocalSettings-local.php' ) )
    require( '/srv/config/exposed/payments/LocalSettings-local.php' );
