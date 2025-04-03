#!/bin/bash
CONTAINER_ID=civicrm

# copy remote civicrm-core source to local
docker compose cp "${CONTAINER_ID}:/srv/civi-sites/dmaster.sh" "./src/civi-sites/dmaster.sh"
echo "container => local: sync complete - ./src/civi-sites/dmaster.sh:/srv/civi-sites/dmaster.sh"

docker compose cp "${CONTAINER_ID}:/srv/civi-sites/dmaster/" "./src/civi-sites"
echo "container => local: sync complete - /srv/civi-sites/dmaster:./src/civi-sites/dmaster"
