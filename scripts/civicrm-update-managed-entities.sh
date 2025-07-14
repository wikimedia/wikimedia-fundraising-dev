#!/bin/bash
echo "*** CiviCRM managed entity update"
docker compose exec -w "/srv/civi-sites/wmf/" civicrm wmf-cv api4 -vv Managed.reconcile
echo "*** Done!"