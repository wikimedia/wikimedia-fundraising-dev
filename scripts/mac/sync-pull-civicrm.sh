#!/bin/bash
CONTAINER_ID=$(docker compose ps -q civicrm)

# copy remote civicrm source to local
docker cp -q "${CONTAINER_ID}:/srv/civi-sites/wmff.sh" "./src/civi-sites/wmff.sh"
echo "container => local: sync complete - ./src/civi-sites/wmff.sh:/srv/civi-sites/wmff.sh"

TEMP_DIR=$(mktemp -d)
docker exec -u0 "${CONTAINER_ID}" chown -R ${FR_DOCKER_UID}:${FR_DOCKER_GID} /srv/civi-sites/wmff
docker cp -q "${CONTAINER_ID}:/srv/civi-sites/wmff" "${TEMP_DIR}"
cp -rf "${TEMP_DIR}/wmff/." "./src/civi-sites/wmff/"
rm -rf "${TEMP_DIR}"
echo "container => local: sync complete - /srv/civi-sites/wmff:./src/civi-sites/wmff"
