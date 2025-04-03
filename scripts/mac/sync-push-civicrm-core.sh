#!/bin/bash
CONTAINER_ID=civicrm

# copy local civicrm-core source to container
if [ -f "./src/civi-sites/dmaster.sh" ]; then
  docker compose cp "./src/civi-sites/dmaster.sh" "${CONTAINER_ID}:/srv/civi-sites/dmaster.sh"
  echo "local => container: sync complete - ./src/civi-sites/dmaster.sh:/srv/civi-sites/dmaster.sh"
fi

if [ -d "./src/civi-sites/dmaster" ]; then
  docker compose exec ${CONTAINER_ID} rm -rf /srv/civi-sites/dmaster
  docker compose cp "./src/civi-sites/dmaster" "${CONTAINER_ID}:/srv/civi-sites"
  echo "local => container: sync complete - ./src/civi-sites/dmaster:/srv/civi-sites/dmaster"
else
  echo "Directory not found: ./src/civi-sites/dmaster"
fi
