#!/bin/bash
echo "*** CiviCRM Synchronize custom fields"
docker compose exec -w "/srv/civi-sites/wmf/" civicrm wmf-cv api4 -vv WMFConfig.syncCustomFields
echo "*** Done!"