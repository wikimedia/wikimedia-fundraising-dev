#!/bin/bash
CONTAINER_ID=civicrm

if [ -d "./src/civicrm-buildkit" ]; then
  docker compose cp "./src/civicrm-buildkit/" "${CONTAINER_ID}:/srv/"
  echo "local => container: sync complete - ./src/civicrm-buildkit:/srv/civicrm-buildkit"
else
  echo "Directory not found: ./src/civicrm-buildkit"
fi
