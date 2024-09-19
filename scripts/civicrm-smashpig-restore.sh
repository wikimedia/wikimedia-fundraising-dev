#!/bin/bash

echo "*** Restore original CiviCRM vendor packages"
docker compose exec civicrm bash -c 'if [ -d "/srv/civi-sites/wmff/vendor" ]; then rm -rf /srv/civi-sites/wmff/vendor; fi'
docker compose exec -w "/srv/civi-sites/wmff/" civicrm composer install
echo "*** CiviCRM vendor/wikimedia/smash-pig now restored"