<?php
# This file should be required by LocalSettings.php for the Fundraising development setup.
#
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
$wgServer = "https://localhost:" . getenv( "FR_DOCKER_PAYMENTS_PORT" );

## The URL path to static resources (images, scripts, etc.)
$wgResourceBasePath = $wgScriptPath;

## The URL paths to the logo.  Make sure you change this from the default,
## or else you'll overwrite your logo when you upgrade!
$wgLogos = [ '1x' => "$wgResourceBasePath/resources/assets/wiki.png" ];

## UPO means: this is also a user preference option

$wgEnableEmail = true;
$wgEnableUserEmail = true; # UPO

$wgEmergencyContact = "apache@localhost";
$wgPasswordSender = "apache@localhost";

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
$wgMemCachedServers = [];

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

require_once "$IP/includes/DevelopmentSettings.php";

// TODO Verify logging settings (currently just as copied from production)
// Capture all PHP log messages to syslog: see https://phabricator.wikimedia.org/T107918
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
                'args' => array( 'mediawiki', 'localhost', 9514, LOG_USER,
                    // Although we only publish messages from the error streams,
                    // note that anything published by wfDebugLog is at the
                    // info level, thus the low bar.
                    Monolog\Logger::INFO,
                ),
                'formatter' => 'line',
            ),
            'blackhole' => array(
                'class' => 'Monolog\Handler\NullHandler',
            ),
        ),
        'loggers' => array(
            'exception' => $syslogLogger,
            'fatal' => $syslogLogger,
            
            // Throw out anything else.  Payments logging is already its
            // own thing, so this only includes MediaWiki logs, below error
            // level.
            '@default' => array( 'handlers' => array( 'blackhole' ) ),
        ),
        'processors' => $defaultProcessors,
    ), ),
);

# Extensions
wfLoadExtension( 'DonationInterface' );

$wgAmazonGatewayEnabled = true;
$wgAmazonGatewayFallbackCurrency = 'USD';
$wgAmazonGatewayNotifyOnConvert = false;
$wgAmazonGatewayAccountInfo['default'] = array(
'WidgetScriptURL' => 'https://static-na.payments-amazon.com/OffAmazonPayments/us/sandbox/js/Widgets.js',
'ReturnURL' => "https://mediawiki.dev/index.php/Special:AmazonGateway?debug=true"
);
$wgAmazonGatewayTestMode = true;
$wgDonationInterfaceEnableFormChooser = true;
$wgGlobalCollectGatewayEnabled = true;
$wgAmazonGatewayEnabled = true;
$wgAdyenGatewayEnabled = true;
$wgAstroPayGatewayEnabled = true;
$wgPaypalGatewayEnabled = true;
$wgPaypalExpressGatewayEnabled = true;
$wgWorldpayGatewayEnabled = true;
$wgAdyenGatewayURL = 'https://test.adyen.com';//'https://live.adyen.com';
$wgAdyenGatewayAccountInfo['XXXX'] = array(
'AccountName' => 'XXXXX',
'SharedSecret' => '',
'SkinCode' => 'XXXX',
);
$wgDonationInterfaceLogDebug = true;
$wgDonationInterfaceUseSyslog = true;
$wgAstroPayGatewayAccountInfo['test'] = array(
'Create' => array( // For creating invoices
'Login' => '',
'Password' => '',
),
'Status' => array( // For checking payment status
'Login' => '',
'Password' => '',
),
'SecretKey' => '', // For signing requests and verifying responses
);
$wgAstroPayGatewayURL = 'https://sandbox.astropaycard.com/';
#$wgAstroPayGatewayTestingURL = 'https://sandbox.astropaycard.com/';
$wgGlobalCollectGatewayURL = 'https://ps.gcsip.nl/wdl/wdl'; // .nl is sandbox
$wgGlobalCollectGatewayMerchantID = 'XXXX';
$wgGlobalCollectGatewayAccountInfo['whatever'] = array(
'MerchantID' => 'XXXX',
);
$wgDonationInterfaceRapidFail = true;
$wgDonationInterfaceFailPage = 'Donate-error';
/** * Antifraud */
$wgDonationInterfaceCustomFiltersFunctions = array(
'getScoreCountryMap' => 100,
'getScoreUtmCampaignMap' => 100,
'getScoreUtmSourceMap' => 9,
'getScoreUtmMediumMap' => 9,
'getScoreEmailDomainMap' => 100,
);
$wgGlobalCollectGatewayCustomFiltersFunctions = $wgDonationInterfaceCustomFiltersFunctions;
$wgGlobalCollectGatewayCustomFiltersFunctions['getCVVResult'] = 50;
$wgGlobalCollectGatewayCustomFiltersFunctions['getAVSResult'] = 50;
$wgAmazonGatewayFallbackCurrency = 'USD';
$wgAmazonGatewayNotifyOnConvert = false;
$wgPaypalGatewayFallbackCurrency = 'USD';
$wgPaypalGatewayNotifyOnConvert = true;
$wgAstroPayGatewayTest = true;
if (is_callable('wfLoadSkin')) {
wfLoadSkin( 'Vector' );
}
$wgDonationInterfaceNoScriptRedirect = 'http://testNoScriptRedirect.example.com/blah';
$wgAstroPayGatewayPriceFloor = 1.5;
$wgAmazonGatewayAccountInfo['default'] = array(
'SellerID' => "XXXXXXX",
'ClientID' => "",
'ClientSecret' => "",
'MWSAccessKey' => "",
'MWSSecretKey' => "",
'Region' => "us",
'WidgetScriptURL' => 'https://static-na.payments-amazon.com/OffAmazonPayments/us/sandbox/js/Widgets.js',
'ReturnURL' => "https://mediawiki.dev/index.php/Special:AmazonGateway?debug=true",);
$wgAmazonGatewayTestMode = true;
$wgAstroPayGatewayFallbackCurrency = 'BRL';
$wgAstroPayGatewayNotifyOnConvert = true;
$wgDonationInterfaceTest = false;
$wgDonationInterfaceTestMode = false;
$wgDonationInterfaceCountryMap = array(
'US' => 10,
);
$wgDonationInterfaceEnableFunctionsFilter = true;
$wgDonationInterfaceKeyMapA = array(
'q',
'w',
'e',
'r',
't',
'a',
's',
'd',
'f',
'g',
'z',
'x',
'c',
'b',
'v');
$wgDonationInterfaceKeyMapB = array(
'y',
'u',
'i',
'o',
'p',
'h',
'j',
'k',
'l',
'b',
'n',
'm'
);
$wgDonationInterfaceNameScore = 10;
$wgDonationInterfaceNameGibberishWeight = .9;
$wgDonationInterfaceCustomFiltersFunctions['getScoreName'] = 10;
$wgDonationInterfaceAllowedHtmlForms['adyen'][0]['countries']['+'] = array( 'US', 'GB', 'CA', 'AU', 'FR' );
$wgDonationInterfaceAllowedHtmlForms['adyen'][0]['currencies']['+'] = array( 'USD', 'GBP', 'CAD', 'AUD', 'EUR' );
$wgDonationInterfaceEmailDomainMap = array(
'bad.com' => 90,
);
$wgDonationInterfaceCustomFiltersActionRanges = array(
'process' => array( 0, 89.99 ),
'review' => array( 90, 100 ),
'challenge' => array( -1, -1 ),
'reject' => array( -1, -1 ),
);
$wgAstroPayGatewayCurlVerboseLog = true;
$wgDonationInterfaceLogCompleted = true;
$wgDonationInterfaceDefaultQueueServer = array(
'type' => '\PHPQueue\Backend\Predis',
'servers' => array(
'scheme' => 'tcp',
'host' => 'localhost',
'port' => 6379,
),
);
$wgDonationInterfaceQueues = array(
"complete" => array( 'queue' => 'donations' ),
);
$wgDonationInterfaceEnableQueue = true;
$wgDonationInterfaceCustomFiltersInitialFunctions = array(
'getScoreUtmCampaignMap' => 100,
);
$wgDonationInterfaceUtmCampaignMap = array(
'/^$/' => 20,
'/badcampaign/' => 100,
);
$wgPaypalExpressGatewayURL = 'https://api-3t.sandbox.paypal.com/nvp';
$wgPaypalExpressGatewayTestingURL = 'https://api-3t.sandbox.paypal.com/nvp';
$wgPaypalExpressGatewaySignatureURL = $wgPaypalExpressGatewayURL;
$wgPaypalExpressGatewayAccountInfo['test'] = array(
'User' => 'fr-tech-facilitator_api1.wikimedia.org',
'Password' => '',
//TODO: 'Credential' => '',
'Signature' => '',
'RedirectURL' => 'https://www.sandbox.paypal.com/cgi-bin/webscr?cmd=_express-checkout&token=',
);
$wgDonationInterfaceTimeout = 25;