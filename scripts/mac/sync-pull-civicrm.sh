#!/bin/bash
CONTAINER_ID=civicrm

# copy remote civicrm source to local
docker compose cp "${CONTAINER_ID}:/srv/civi-sites/wmff.sh" "./src/civi-sites/wmff.sh"
echo "container => local: sync complete - ./src/civi-sites/wmff.sh:/srv/civi-sites/wmff.sh"

docker compose cp "${CONTAINER_ID}:/srv/civi-sites/wmff/" /srv/civi-sites

echo "container => local: sync complete - /srv/civi-sites/wmff:./src/civi-sites/wmff"
