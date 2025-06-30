#!/bin/bash
CONTAINER_ID=civicrm

# copy local civicrm standalone source to container
if [ -f "./src/civi-sites/wmf.sh" ]; then
  docker compose cp "./src/civi-sites/wmf.sh" "${CONTAINER_ID}:/srv/civi-sites/wmf.sh"
  echo "local => container: sync complete - ./src/civi-sites/wmf.sh:/srv/civi-sites/wmf.sh"
fi

if [ -d "./src/civi-sites/wmf" ]; then
  docker compose cp "./src/civi-sites/wmf/" "${CONTAINER_ID}:/srv/civi-sites/"
  echo "local => container: sync complete - ./src/civi-sites/wmf:/srv/civi-sites/wmf"
else
  echo "Directory not found: ./src/civi-sites/wmf"
fi
