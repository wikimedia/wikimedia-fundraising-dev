#!/bin/bash
echo "*** CiviCRM Synchronize custom fields"
docker compose exec -w "/srv/civi-sites/wmff/drupal/" civicrm cv api4 --user=admin -vv WMFConfig.syncCustomFields
echo "*** Done!"