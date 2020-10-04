#!/bin/bash

docker-compose exec -w "/var/www/html/" \
	mediawiki-payments php tests/phpunit/phpunit.php --group DonationInterface