#!/bin/bash
CONTAINER_ID=$(docker compose ps -q civicrm)
CIVICRM_SERVICE_NAME="civicrm"

# copy remote civicrm source to local
docker cp -q "${CONTAINER_ID}:/srv/civi-sites/wmff" "./src/civi-sites/wmff"
docker cp -q "${CONTAINER_ID}:/srv/civi-sites/wmff".sh "./src/civi-sites/wmff.sh"
echo "container => local: sync complete - ./src/civi-sites/wmff:/srv/civi-sites/wmff"
echo "container => local: sync complete - ./src/civi-sites/wmff.sh:/srv/civi-sites/wmff.sh"


