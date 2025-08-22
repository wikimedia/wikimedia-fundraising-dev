#!/bin/bash

echo "*** Restore original Email Preference Center vendor packages"
docker compose exec email-pref-ctr bash -c 'if [ -d "/var/www/html/vendor" ]; then rm -rf /var/www/html/vendor; fi'
docker compose exec -w "/var/www/html/" email-pref-ctr git submodule update --init vendor
echo "*** Email Preference Center vendor/wikimedia/smash-pig now restored"
