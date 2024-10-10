#!/bin/bash
echo "*** CiviCRM managed entity update"
docker compose exec -w "/srv/civi-sites/wmff/drupal/" civicrm cv api4 --user=admin -vv Managed.reconcile
echo "*** Done!"