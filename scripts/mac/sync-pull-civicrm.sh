#!/bin/bash
CONTAINER_ID=civicrm

# copy remote civicrm source to local
docker compose cp "${CONTAINER_ID}:/srv/civi-sites/wmf.sh" "./src/civi-sites/wmf.sh"
echo "container => local: sync complete - ./srv/civi-sites/wmf.sh:/src/civi-sites/wmf.sh"

docker compose cp "${CONTAINER_ID}:/srv/civi-sites/wmf/" "./src/civi-sites/"
echo "container => local: sync complete - /srv/civi-sites/wmf:./src/civi-sites/wmf"

docker compose cp "${CONTAINER_ID}:/srv/config/exposed/civicrm/amp/apache.d/" "./config/civicrm/amp/"
echo "container => local: sync complete - /srv/config/exposed/civicrm/amp/apache.d:./config/civicrm/amp/apache.d"
