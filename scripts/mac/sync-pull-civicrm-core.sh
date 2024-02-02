#!/bin/bash
CONTAINER_ID=$(docker compose ps -q civicrm)

# copy remote civicrm-core source to local
docker cp -q "${CONTAINER_ID}:/srv/civi-sites/dmaster.sh" "./src/civi-sites/dmaster.sh"
echo "container => local: sync complete - ./src/civi-sites/dmaster.sh:/srv/civi-sites/dmaster.sh"

TEMP_DIR=$(mktemp -d)
docker exec -u0 "${CONTAINER_ID}" chown -R ${FR_DOCKER_UID}:${FR_DOCKER_GID} /srv/civi-sites/dmaster
docker cp -q "${CONTAINER_ID}:/srv/civi-sites/dmaster" "${TEMP_DIR}"
cp -rf "${TEMP_DIR}/dmaster/." "./src/civi-sites/dmaster/"
rm -rf "${TEMP_DIR}"
echo "container => local: sync complete - /srv/civi-sites/dmaster:./src/civi-sites/dmaster"
