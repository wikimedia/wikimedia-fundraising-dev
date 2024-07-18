#!/bin/bash

if [ $# -eq 0 ]; then
  docker compose exec -w "/srv/civi-sites/wmff/drupal" civicrm /bin/bash
else
  docker compose exec -w "/srv/civi-sites/wmff/drupal" civicrm drush "$@"
fi
