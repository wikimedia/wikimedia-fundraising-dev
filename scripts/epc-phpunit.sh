#!/bin/bash

docker compose exec -w "/var/www/html/" \
	email-pref-ctr php tests/phpunit/phpunit.php --group DonationInterface --ignore-dependencies $@
