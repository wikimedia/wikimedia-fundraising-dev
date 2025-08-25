#!/bin/bash
CONTAINER_ID=civicrm

# copy remote civicrm source to local
docker compose cp "${CONTAINER_ID}:/srv/civi-sites/wmf.sh" "./src/civi-sites/wmf.sh"
echo "container => local: sync complete - ./src/civi-sites/wmf.sh:/srv/civi-sites/wmf.sh"

docker compose cp "${CONTAINER_ID}:/srv/civi-sites/wmf/" "./src/civi-sites/"

echo "container => local: sync complete - /srv/civi-sites/wmf:./src/civi-sites/wmf"
