#!/bin/bash

echo "*** CiviCRM consume recurring contribution id"
docker compose exec -w "/srv/civi-sites/wmf/" civicrm wmf-cv -vv api3 job.process_smashpig_recurring contribution_recur_id=$@
echo "*** Done!"