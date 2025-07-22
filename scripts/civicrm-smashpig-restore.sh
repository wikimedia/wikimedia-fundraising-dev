#!/bin/bash

echo "*** Restore original CiviCRM vendor packages"
docker compose exec civicrm bash -c 'if [ -d "/srv/civi-sites/wmf/vendor" ]; then rm -rf /srv/civi-sites/wmf/vendor; fi'
docker compose exec -w "/srv/civi-sites/wmf/" civicrm composer install
echo "*** CiviCRM vendor/wikimedia/smash-pig now restored"
