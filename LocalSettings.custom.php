require_once "$IP/includes/DevelopmentSettings.php";

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