#!/bin/bash
echo "*** CiviCRM database upgrade"
docker compose exec -w "/srv/civi-sites/wmf/" civicrm wmf-cv -vv upgrade:db
echo "*** Done!"