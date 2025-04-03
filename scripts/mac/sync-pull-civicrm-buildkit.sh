#!/bin/bash

# copy remote civicrm-buildkit to local
docker compose cp "${CONTAINER_ID}:/srv/civicrm-buildkit/" "./src"
echo "container => local: sync complete - ./srv/civicrm-buildkit:./src/civicrm-buildkit"
echo
