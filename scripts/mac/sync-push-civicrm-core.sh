#!/bin/bash
CONTAINER_ID=$(docker compose ps -q civicrm)

# copy local civicrm-core source to container
if [ -f "./src/civi-sites/dmaster.sh" ]; then
  docker cp -q "./src/civi-sites/dmaster.sh" "${CONTAINER_ID}:/srv/civi-sites/dmaster.sh"
  docker exec "${CONTAINER_ID}" chown "${FR_DOCKER_UID}":"${FR_DOCKER_GID}" /srv/civi-sites/dmaster.sh
  echo "local => container: sync complete - ./src/civi-sites/dmaster.sh:/srv/civi-sites/dmaster.sh"
fi

if [ -d "./src/civi-sites/dmaster" ]; then
  docker cp -q "./src/civi-sites/dmaster" "${CONTAINER_ID}:/tmp/dmaster"
  docker exec -u0 "${CONTAINER_ID}" mkdir -p /srv/civi-sites/dmaster
  docker exec -u0 "${CONTAINER_ID}" chown -R "${FR_DOCKER_UID}":"${FR_DOCKER_GID}" /tmp/dmaster /srv/civi-sites/dmaster
  docker exec "${CONTAINER_ID}" cp -rf /tmp/dmaster/. /srv/civi-sites/dmaster/
  docker exec "${CONTAINER_ID}" rm -rf /tmp/dmaster
  echo "local => container: sync complete - ./src/civi-sites/dmaster:/srv/civi-sites/dmaster"
else
  echo "Directory not found: ./src/civi-sites/dmaster"
fi
