#!/bin/bash

echo "*** Restore original Payments-wiki vendor packages"
docker compose exec payments bash -c 'if [ -d "/var/www/html/vendor" ]; then rm -rf /var/www/html/vendor; fi'
docker compose exec -w "/var/www/html/" payments git submodule update --init vendor
echo "*** Payments-wiki vendor/wikimedia/smash-pig now restored"