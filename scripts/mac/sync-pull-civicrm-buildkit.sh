#!/bin/bash

# copy remote civicrm-buildkit to local
TEMP_DIR=$(mktemp -d)
docker exec -u0 "${CONTAINER_ID}" chown -R ${FR_DOCKER_UID}:${FR_DOCKER_GID} /srv/civicrm-buildkit
docker cp -q "${CONTAINER_ID}:/srv/civicrm-buildkit" "${TEMP_DIR}"
cp -rf "${TEMP_DIR}/civicrm-buildkit/." "./src/civicrm-buildkit"
rm -rf "${TEMP_DIR}"
echo "container => local: sync complete - ./srv/civicrm-buildkit:./src/civicrm-buildkit"
echo
