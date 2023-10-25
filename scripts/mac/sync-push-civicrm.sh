#!/bin/bash
CONTAINER_ID=$(docker compose ps -q civicrm)
CIVICRM_SERVICE_NAME="civicrm"


# loop through each folder in the ./config/* and copy to /srv/config/exposed/
for config_dir in ./config/*; do
  if [ -d "$config_dir" ]; then
    app_name=$(basename "$config_dir")
    docker compose exec "$CIVICRM_SERVICE_NAME" rm -rf /srv/config/exposed/$app_name
    docker cp -q $config_dir "$CONTAINER_ID:/srv/config/exposed/$app_name"
  fi
done
echo "sync complete - ./config/*:/srv/config/exposed/"

# loop through each folder in the ./config-private/* and copy to /srv/config/private/
for config_private_dir in ./config-private/*; do
  if [ -d "$config_private_dir" ]; then
    app_private_name=$(basename "$config_private_dir")
    docker compose exec "$CIVICRM_SERVICE_NAME" rm -rf /srv/config/private/$app_private_name
    docker cp -q $config_private_dir "$CONTAINER_ID:/srv/config/private/$app_private_name"
  fi
done
echo "sync complete - ./config-private/*:/srv/config/private/"

# copy local civicrm source to container
docker cp -q "./src/civi-sites/wmff" "${CONTAINER_ID}:/srv/civi-sites/wmff"
docker cp -q "./src/civi-sites/wmff.sh" "${CONTAINER_ID}:/srv/civi-sites/wmff".sh
echo "local => container: sync complete - ./src/civi-sites/wmff:/srv/civi-sites/wmff"
echo "local => container: sync complete - ./src/civi-sites/wmff.sh:/srv/civi-sites/wmff.sh"


