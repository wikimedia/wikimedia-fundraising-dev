#!/bin/bash

docker compose exec -w "/var/www/html/" payments composer phpunit -- --group DonationInterface --ignore-dependencies $@
