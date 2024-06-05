#!/bin/bash
CONTAINER_ID=$(docker compose ps -q civicrm)

# copy remote civicrm standalone source to local
docker cp -q "${CONTAINER_ID}:/srv/civi-sites/standalone-dev.sh" "./src/civi-sites/standalone-dev.sh"
echo "container => local: sync complete - ./src/civi-sites/standalone-dev.sh:/srv/civi-sites/standalone-dev.sh"

TEMP_DIR=$(mktemp -d)
docker exec -u0 "${CONTAINER_ID}" chown -R ${FR_DOCKER_UID}:${FR_DOCKER_GID} /srv/civi-sites/standalone-dev
docker cp -q "${CONTAINER_ID}:/srv/civi-sites/standalone-dev" "${TEMP_DIR}"
cp -rf "${TEMP_DIR}/standalone-dev/." "./src/civi-sites/standalone-dev/"
rm -rf "${TEMP_DIR}"
echo "container => local: sync complete - /srv/civi-sites/standalone-dev:./src/civi-sites/standalone-dev"
