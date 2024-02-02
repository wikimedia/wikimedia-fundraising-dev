#!/bin/bash
CONTAINER_ID=$(docker compose ps -q civicrm)

if [ -f "./src/civi-sites/wmff.sh" ]; then
  docker cp -q "./src/civi-sites/wmff.sh" "${CONTAINER_ID}:/srv/civi-sites/wmff.sh"
  docker exec "${CONTAINER_ID}" chown ${FR_DOCKER_UID}:${FR_DOCKER_GID} /srv/civi-sites/wmff.sh
  echo "local => container: sync complete - ./src/civi-sites/wmff.sh:/srv/civi-sites/wmff.sh"
fi

if [ -d "./src/civi-sites/wmff" ]; then
  docker cp -q "./src/civi-sites/wmff" "${CONTAINER_ID}:/tmp/wmff"
  docker exec -u0 "${CONTAINER_ID}" mkdir -p /srv/civi-sites/wmff
  docker exec -u0 "${CONTAINER_ID}" chown -R "${FR_DOCKER_UID}":"${FR_DOCKER_GID}" /tmp/wmff /srv/civi-sites/wmff
  docker exec "${CONTAINER_ID}" cp -rf /tmp/wmff/. /srv/civi-sites/wmff/
  docker exec "${CONTAINER_ID}" rm -rf /tmp/wmff
  echo "local => container: sync complete - ./src/civi-sites/wmff:/srv/civi-sites/wmff"
else
  echo "Directory not found: ./src/civi-sites/wmff"
fi
