#!/bin/bash
CONTAINER_ID=civicrm

# copy remote civicrm standalone source to local
docker compose cp "${CONTAINER_ID}:/srv/civi-sites/standalone-clean.sh" "./src/civi-sites/standalone-clean.sh"
echo "container => local: sync complete - ./src/civi-sites/standalone-clean.sh:/srv/civi-sites/standalone-clean.sh"

docker compose cp "${CONTAINER_ID}:/srv/civi-sites/standalone-clean/" "./src/civi-sites"
echo "container => local: sync complete - /srv/civi-sites/standalone-clean:./src/civi-sites/standalone-clean"
