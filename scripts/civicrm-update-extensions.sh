#!/bin/bash
echo "*** CiviCRM extensions upgrade"
docker compose exec -w "/srv/civi-sites/wmf/" civicrm wmf-cv -vv updb
echo "*** Done!"