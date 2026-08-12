<?php

use MediaWiki\Maintenance\Maintenance;
use MediaWiki\User\User;

// @codeCoverageIgnoreStart
$IP = getenv( 'MW_INSTALL_PATH' );
if ( $IP === false ) {
	$IP = __DIR__ . '/../../..';
}
require_once "$IP/maintenance/Maintenance.php";
// @codeCoverageIgnoreEnd

/**
 * Creates a new banner to test
 */
class CreateLeadGenBanner extends Maintenance {
	public function __construct() {
		parent::__construct();
		$this->requireExtension( 'CentralNotice' );
		$this->addDescription(
			'Adds a banner to a local wiki for testing cross-origin lead generation forms.'
		);
	}

	public function execute() {
		$user = User::newSystemUser( User::MAINTENANCE_SCRIPT_USER, [ 'steal' => true ] );

		$bannerContents = file_get_contents( __DIR__ . '/LeadGenBanner.wiki' );
		if ( Banner::fromName( 'leadgen' )->exists() ) {
			$this->output( "Banner 'leadgen' already exists; updating.\n" );
			Banner::fromName( 'leadgen' )->setBodyContent( $bannerContents )->save( $user );
		} else {
			Banner::addBanner(
				name: 'leadgen',
				body: $bannerContents,
				user: $user,
				displayAnon: true,
				displayAccount: true
			);
			$this->output( "Created banner 'leadgen'.\n" );
		}

		if ( Campaign::campaignExists( 'LeadGenCampaign' ) ) {
			$this->output( "Campaign 'LeadGenCampaign' already exists; skipping.\n" );
		} else {
			Campaign::addCampaign(
				noticeName: 'LeadGenCampaign',
				enabled: true,
				startTs: wfTimestamp( TS_MW ),
				projects: [ 'donut' ],
				project_languages: [ 'en' ],
				geotargeted: false,
				geo_countries: [],
				geo_regions: [],
				throttle: 100,
				priority: CentralNotice::NORMAL_PRIORITY,
				user: $user,
				type: null
			);
			Campaign::addTemplateTo( 'LeadGenCampaign', 'leadgen', 25 );
			$this->output( "Created campaign 'LeadGenCampaign' with banner 'leadgen'.\n" );
		}
	}
}

// @codeCoverageIgnoreStart
$maintClass = CreateLeadGenBanner::class;
require_once RUN_MAINTENANCE_IF_MAIN;
// @codeCoverageIgnoreEnd
