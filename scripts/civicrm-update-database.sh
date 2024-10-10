#!/bin/bash
echo "*** CiviCRM database upgrade"
docker compose exec -w "/srv/civi-sites/wmff/drupal/" civicrm cv --user=admin -vv upgrade:db
echo "*** Done!"