#!/bin/bash
CONTAINER_ID=$(docker compose ps -q civicrm)
docker cp -q ./src/civicrm-buildkit "${CONTAINER_ID}:/srv/civicrm-buildkit"
echo "local => container: sync complete - ./src/civicrm-buildkit:/srv/civicrm-buildkit"
