#!/bin/bash
CONTAINER_ID=$(docker compose ps -q civicrm)

# copy local civicrm standalone source to container
if [ -f "./src/civi-sites/standalone-dev.sh" ]; then
  docker cp -q "./src/civi-sites/standalone-dev.sh" "${CONTAINER_ID}:/srv/civi-sites/standalone-dev.sh"
  docker exec "${CONTAINER_ID}" chown "${FR_DOCKER_UID}":"${FR_DOCKER_GID}" /srv/civi-sites/standalone-dev.sh
  echo "local => container: sync complete - ./src/civi-sites/standalone-dev.sh:/srv/civi-sites/standalone-dev.sh"
fi

if [ -d "./src/civi-sites/standalone-dev" ]; then
  docker cp -q "./src/civi-sites/standalone-dev" "${CONTAINER_ID}:/tmp/standalone-dev"
  docker exec -u0 "${CONTAINER_ID}" mkdir -p /srv/civi-sites/standalone-dev
  docker exec -u0 "${CONTAINER_ID}" chown -R "${FR_DOCKER_UID}":"${FR_DOCKER_GID}" /tmp/standalone-dev /srv/civi-sites/standalone-dev
  docker exec "${CONTAINER_ID}" cp -rf /tmp/standalone-dev/. /srv/civi-sites/standalone-dev/
  docker exec "${CONTAINER_ID}" rm -rf /tmp/standalone-dev
  echo "local => container: sync complete - ./src/civi-sites/standalone-dev:/srv/civi-sites/standalone-dev"
else
  echo "Directory not found: ./src/civi-sites/standalone-dev"
fi
