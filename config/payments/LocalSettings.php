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

## The protocol and server name to use in fully-qualified URLs
$wgServer = "https://localhost:" . getenv( "FR_DOCKER_MW_PORT" );

## The URL path to static resources (images, scripts, etc.)
$wgResourceBasePath = $wgScriptPath;

## The URL paths to the logo.  Make sure you change this from the default,
## or else you'll overwrite your logo when you upgrade!
$wgLogos = [ '1x' => "$wgResourceBasePath/resources/assets/wiki.png" ];

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

### Settings below are based on settings for staging in the localsettings repo,
### at commit c6a5b1dac95876199.

# TODO Check all these, too.

$wgUseFileCache = true;
$wgCacheDirectory = '/tmp/'; # Different value from staging
$wgFileCacheDirectory = "{$wgCacheDirectory}/html";
$wgLocalisationUpdateDirectory = "{$wgCacheDirectory}/l10n";

# NoLogin
function NoLoginLinkOnMainPage(&$personal_urls){
	unset($personal_urls['anonlogin']);
	unset($personal_urls['login']);
	unset($personal_urls['login-private']);
	unset($personal_urls['anonuserpage']);
	unset($personal_urls['anontalk']);
	return true;
}
$wgHooks['PersonalUrls'][]='NoLoginLinkOnMainPage';

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

$wgLogo = "/images/e/eb/Wmf_logo.png";
$wgLogoHD = array(
	"1.5x" => "/images/f/fc/Wmf_logo_1.5x.png",
	"2x" => "/images/d/d1/Wmf_logo_2x.png"
);

$wgGroupPermissions['*']['createaccount'] = false;
$wgGroupPermissions['*']['edit'] = false;
$wgGroupPermissions['*']['read'] = false;
$wgGroupPermissions['user']['edit'] = false;
$wgGroupPermissions['sysop']['edit'] = false;
$wgGroupPermissions['sysop']['edit'] = 1;
$wgWhitelistRead =  array (
	"Special:GlobalCollectGatewayResult",
	"Special:GlobalCollectGateway",
	"2010_Landing_9/en",
	"-",
	"MediaWiki:Common.css",
	"MediaWiki:Print.css",
	"MediaWiki:Vector.css",
	"Donate-error",
	"Special:GatewayFormChooser",
	"Special:AmazonGateway",
	"Special:FundraiserMaintenance",
	"Special:FundraiserUnsubscribe",
	"Special:FundraiserSubscribe",
	"Special:OptIn",
	"Special:EmailPreferences",
	"Special:SystemStatus",
	"Special:PaypalGateway",
	"Special:PaypalExpressGateway",
	"Special:PaypalExpressGatewayResult",
	"Special:PaypalLegacyGateway",
	"Special:AdyenGateway",
	"Special:AdyenGatewayResult",
	"Special:AstroPayGateway",
	"Special:AstroPayGatewayResult",
	"Special:IngenicoGatewayResult",
	"Special:IngenicoGateway",
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
$wgDonationInterfaceDefaultQueueServer = array(
	'type' => '\PHPQueue\Backend\Predis',
	'servers' => array(
		'scheme' => 'tcp',
		'host' => 'queues',
		'port' => 6379,
	),
	# On staging expiry is set to one month. TODO Set it here, too?
	# 'expiry' => 2592000,
);

# Endowment logo
$wgDonationInterfaceLogoOverride = [
	[
		'variable' => 'utm_medium',
		'value' => 'endowment',
		'logo' => '/images/4/49/Wikimedia_Endowment.png',
		'logoHD' => [
			'1.5x' => '/images/4/49/Wikimedia_Endowment_1.5x.png',
			'2x' => '/images/8/85/Wikimedia_Endowment_2x.png',
		]
	]
];

# Gateways
$wgAdyenGatewayEnabled = true;
$wgAmazonGatewayEnabled = true;
$wgAstroPayGatewayEnabled = true;
$wgGlobalCollectGatewayEnabled = true;
$wgIngenicoGatewayEnabled = true;
$wgPaypalGatewayEnabled = true;
$wgPaypalExpressGatewayEnabled = true;

# TODO Deprecate this, remove relateed code, something? Not present on staging, but mentioned
# in documentation on mediawiki.org
# $wgWorldpayGatewayEnabled = false;

# Components
$wgDonationInterfaceEnableReferrerFilter = true;
$wgDonationInterfaceEnableSourceFilter = true;
$wgDonationInterfaceEnableFunctionsFilter = true;
$wgDonationInterfaceEnableConversionLog = true;

# The setting below is enbaled on staging, but it's best to leave it off for dev setup
$wgDonationInterfaceEnableIPVelocityFilter = false;

$wgDonationInterfaceEnableFormChooser = true;
$wgDonationInterfaceEnableSessionVelocityFilter = true;
$wgDonationInterfaceEnableSystemStatus = true;
$wgDonationInterfaceEnableQueue = true;
$wgDonationInterfaceEnableBannerHistoryLog = true;

# As per vagrant, leaving this off, though it's on for staging. Also not setting
# $wgDonationInterfaceMinFraudWeight, which is set on staging. See private
# settings for related stuff. TODO Check this.
$wgDonationInterfaceEnableMinFraud = false;

$wgDonationInterfaceThankYouPage = 'https://thankyou.wikipedia.org/wiki/Thank_You';
$wgDonationInterfacePriceCeiling = 12000;

$wgDonationInterfaceHeader = "{{2010/Donate-banner/@language}}";

# Value on staging: 'http://wikimediafoundation.org/wiki/DonateNonJS/en'
$wgDonationInterfaceNoScriptRedirect = 'http://testNoScriptRedirect.example.com/blah';

$wgDonationInterfaceUseSyslog = true;
$wgDonationInterfaceExtrasLog = 'syslog'; # Removed conditional from staging config
$wgDonationInterfaceSaveCommStats = true;
$wgDonationInterfaceTimeout = 12; # Comment from staging: Can't seem to override this for PayPal EC, trying here in desperation

$wgIngenicoGatewayHostedFormVariants = [ 'iframe' => 102, 'redirect' => 101 ];

$wgDonationInterfaceRapidFail = true;
$wgGlobalCollectGatewayFailPage = 'donate-error';

# Always notify donor when we automatically switch currency.
$wgDonationInterfaceNotifyOnConvert = true;

$wgFundraisingEmailUnsubscribeQueueClass = 'PHPQueue\Backend\Predis';
$wgFundraisingEmailUnsubscribeQueueParameters = array(
	'unsubscribe' => $wgDonationInterfaceDefaultQueueServer,
	'opt-in' => $wgDonationInterfaceDefaultQueueServer,
);

### Set form_variants directory. This value is specific to our Docker setup. The setting
### is also on vagrant and staging, with different values.
$wgDonationInterfaceVariantConfigurationDirectory =
	'/var/www/html/extensions/DonationInterface/form_variants';

# ZOMG DIRE EMERGENCY aka shut down gracefully :p
# $wgDonationInterfaceFundraiserMaintenance = true;

# Monthly convert: uncomment and set this to test default country-based monthly convert
# $wgDonationInterfaceMonthlyConvertCountries = [ 'XX' ];

# TODO What do do about this setting? Below is the value it's at in both
# staging and vagrant.
# $wgDonationInterfaceMemcacheHost = 'localhost';

# TODO How should we set $wgDonationInterfaceLocalConfigurationDirectory?
# On staging, it's set to '/srv/www/org/wikimedia/payments/di-config'.

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
# They are: $wgAstroPayGatewayTest, $wgPaypalGatewayTest and $wgGlobalCollectGatewayTest,
# $wgAdyenGatewayTest, $wgAmazonGatewayTest (different from above). TODO Check this, and maybe
# move those settings here.

# This following settings only appear in the mediawiki.org documentation.
$wgAmazonGatewayTestMode = true;
$wgDonationInterfaceFailPage = 'Donate-error';
$wgDonationInterfaceLogCompleted = true; # Apperently never read in the code

$wgDonationInterfaceLogDebug = false;
$wgGlobalCollectGatewayLogCompleted = true;
$wgIngenicoGatewayLogCompleted = true;
$wgIngenicoGatewayCurlVerboseLog = true;
$wgAmazonGatewayLogDebug = true;
$wgAstroPayGatewayCurlVerboseLog = true;

### Include private settings
require( '/srv/config/private/payments/LocalSettings-private.php' );
