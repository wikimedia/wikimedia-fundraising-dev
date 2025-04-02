#!/bin/bash
CONTAINER_ID=$(docker compose ps -q civicrm)

# copy remote civicrm standalone source to local
docker cp -q "${CONTAINER_ID}:/srv/civi-sites/standalone-clean.sh" "./src/civi-sites/standalone-clean.sh"
echo "container => local: sync complete - ./src/civi-sites/standalone-clean.sh:/srv/civi-sites/standalone-clean.sh"

TEMP_DIR=$(mktemp -d)
docker exec -u0 "${CONTAINER_ID}" chown -R ${FR_DOCKER_UID}:${FR_DOCKER_GID} /srv/civi-sites/standalone-clean
docker cp -q "${CONTAINER_ID}:/srv/civi-sites/standalone-clean" "${TEMP_DIR}"
cp -rf "${TEMP_DIR}/standalone-clean/." "./src/civi-sites/standalone-clean/"
rm -rf "${TEMP_DIR}"
echo "container => local: sync complete - /srv/civi-sites/standalone-clean:./src/civi-sites/standalone-clean"
