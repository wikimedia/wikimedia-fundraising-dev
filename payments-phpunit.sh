#!/bin/bash

docker-compose exec -w "/var/www/html/" \
	payments php tests/phpunit/phpunit.php --group DonationInterface