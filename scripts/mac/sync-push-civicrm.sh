#!/bin/bash
CONTAINER_ID=civicrm

if [ -f "./src/civi-sites/wmff.sh" ]; then
  docker compose cp "./src/civi-sites/wmff.sh" "${CONTAINER_ID}:/srv/civi-sites/wmff.sh"
  echo "local => container: sync complete - ./src/civi-sites/wmff.sh:/srv/civi-sites/wmff.sh"
fi

if [ -d "./src/civi-sites/wmff" ]; then
  docker compose cp "./src/civi-sites/wmff" "${CONTAINER_ID}:/srv/civi-sites/"
  echo "local => container: sync complete - ./src/civi-sites/wmff:/srv/civi-sites/wmff"
else
  echo "Directory not found: ./src/civi-sites/wmff"
fi
