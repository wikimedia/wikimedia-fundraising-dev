#!/bin/bash
CONTAINER_ID=$(docker compose ps -q civicrm)

# copy local civicrm standalone source to container
if [ -f "./src/civi-sites/standalone-clean.sh" ]; then
  docker cp -q "./src/civi-sites/standalone-clean.sh" "${CONTAINER_ID}:/srv/civi-sites/standalone-clean.sh"
  docker exec "${CONTAINER_ID}" chown "${FR_DOCKER_UID}":"${FR_DOCKER_GID}" /srv/civi-sites/standalone-clean.sh
  echo "local => container: sync complete - ./src/civi-sites/standalone-clean.sh:/srv/civi-sites/standalone-clean.sh"
fi

if [ -d "./src/civi-sites/standalone-clean" ]; then
  docker cp -q "./src/civi-sites/standalone-clean" "${CONTAINER_ID}:/tmp/standalone-clean"
  docker exec -u0 "${CONTAINER_ID}" mkdir -p /srv/civi-sites/standalone-clean
  docker exec -u0 "${CONTAINER_ID}" chown -R "${FR_DOCKER_UID}":"${FR_DOCKER_GID}" /tmp/standalone-clean /srv/civi-sites/standalone-clean
  docker exec "${CONTAINER_ID}" cp -rf /tmp/standalone-clean/. /srv/civi-sites/standalone-clean/
  docker exec "${CONTAINER_ID}" rm -rf /tmp/standalone-clean
  echo "local => container: sync complete - ./src/civi-sites/standalone-clean:/srv/civi-sites/standalone-clean"
else
  echo "Directory not found: ./src/civi-sites/standalone-clean"
fi
