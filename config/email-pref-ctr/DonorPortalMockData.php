<?php
$mockData = str_replace( 'module.exports = exports = ', '',
	file_get_contents( '/var/www/html/extensions/DonationInterface/tests/jest/mocks/donor_data.mock.js' )
);
$mockData = preg_replace( '/\n(\s+)([a-zA-Z_]+):/', '$1"$2":', $mockData );
$mockData = str_replace( "'", '"', $mockData );
$mockData = preg_replace( '/;$/', '', $mockData );
$wgDonorPortalMockData = json_decode($mockData, true);
