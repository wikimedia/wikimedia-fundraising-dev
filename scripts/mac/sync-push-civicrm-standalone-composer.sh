#!/bin/bash
CONTAINER_ID=civicrm

# copy local civicrm standalone source to container
if [ -f "./src/civi-sites/standalone-composer.sh" ]; then
  docker compose cp "./src/civi-sites/standalone-composer.sh" "${CONTAINER_ID}:/srv/civi-sites/standalone-composer.sh"
  echo "local => container: sync complete - ./src/civi-sites/standalone-composer.sh:/srv/civi-sites/standalone-composer.sh"
fi

if [ -d "./src/civi-sites/standalone-composer" ]; then
  docker compose cp "./src/civi-sites/standalone-composer/" "${CONTAINER_ID}:/srv/civi-sites/"
  echo "local => container: sync complete - ./src/civi-sites/standalone-composer:/srv/civi-sites/standalone-composer"
else
  echo "Directory not found: ./src/civi-sites/standalone-composer"
fi
