#!/bin/bash
CONTAINER_ID=civicrm

# copy local civicrm standalone source to container
if [ -f "./src/civi-sites/standalone-clean.sh" ]; then
  docker compose cp "./src/civi-sites/standalone-clean.sh" "${CONTAINER_ID}:/srv/civi-sites/standalone-clean.sh"
  echo "local => container: sync complete - ./src/civi-sites/standalone-clean.sh:/srv/civi-sites/standalone-clean.sh"
fi

if [ -d "./src/civi-sites/standalone-clean" ]; then
  docker compose exec ${CONTAINER_ID} rm -rf /srv/civi-sites/standalone-clean
  docker compose cp "./src/civi-sites/standalone-clean/" "${CONTAINER_ID}:/srv/civi-sites/"
  echo "local => container: sync complete - ./src/civi-sites/standalone-clean:/srv/civi-sites/standalone-clean"
else
  echo "Directory not found: ./src/civi-sites/standalone-clean"
fi
