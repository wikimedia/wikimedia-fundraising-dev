#!/bin/bash
echo "*** CiviCRM extensions upgrade"
docker compose exec -w "/srv/civi-sites/wmff/drupal/" civicrm cv --user=admin -vv updb
echo "*** Done!"