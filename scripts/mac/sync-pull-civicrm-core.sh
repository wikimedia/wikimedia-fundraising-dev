#!/bin/bash
CONTAINER_ID=$(docker compose ps -q civicrm)
CIVICRM_SERVICE_NAME="civicrm"

# copy remote civicrm-core source to local
docker cp -q "${CONTAINER_ID}:/srv/civi-sites/dmaster" "./src/civi-sites/dmaster"
docker cp -q "${CONTAINER_ID}:/srv/civi-sites/dmaster".sh "./src/civi-sites/dmaster.sh"
echo "container => local: sync complete - ./src/civi-sites/dmaster:/srv/civi-sites/dmaster"
echo "container => local: sync complete - ./src/civi-sites/dmaster.sh:/srv/civi-sites/dmaster.sh"