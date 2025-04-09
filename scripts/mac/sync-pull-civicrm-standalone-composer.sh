#!/bin/bash
CONTAINER_ID=civicrm

# copy remote civicrm standalone source to local
docker compose cp "${CONTAINER_ID}:/srv/civi-sites/standalone-composer.sh" "./src/civi-sites/standalone-composer.sh"
echo "container => local: sync complete - ./src/civi-sites/standalone-composer.sh:/srv/civi-sites/standalone-composer.sh"

docker compose cp "${CONTAINER_ID}:/srv/civi-sites/standalone-composer/" "./src/civi-sites"
echo "container => local: sync complete - /srv/civi-sites/standalone-composer:./src/civi-sites/standalone-composer"
