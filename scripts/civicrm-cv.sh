#!/bin/bash

if [ $# -eq 0 ]; then
  echo "*** CiviCRM list commands"
  docker compose exec -w "/srv/civi-sites/wmf/" civicrm /srv/civicrm-buildkit/bin/cv list
else
  echo "*** CiviCRM run cv command: $@"
  docker compose exec -w "/srv/civi-sites/wmf/" civicrm /srv/civicrm-buildkit/bin/cv -vv "$@"
fi
echo "*** Done!"