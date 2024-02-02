#!/bin/bash
CONTAINER_ID=$(docker compose ps -q civicrm)

if [ -d "./src/civicrm-buildkit" ]; then
  docker cp -q "./src/civicrm-buildkit" "${CONTAINER_ID}:/tmp/civicrm-buildkit"
  docker exec -u0 "${CONTAINER_ID}" mkdir -p /srv/civicrm-buildkit
  docker exec -u0 "${CONTAINER_ID}" chown -R "${FR_DOCKER_UID}":"${FR_DOCKER_GID}" /tmp/civicrm-buildkit /srv/civicrm-buildkit
  docker exec "${CONTAINER_ID}" cp -rf /tmp/civicrm-buildkit/. /srv/civicrm-buildkit/
  docker exec "${CONTAINER_ID}" rm -rf /tmp/civicrm-buildkit
  echo "local => container: sync complete - ./src/civicrm-buildkit:/srv/civicrm-buildkit"
else
  echo "Directory not found: ./src/civicrm-buildkit"
fi
