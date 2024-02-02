#!/bin/bash
CONTAINER_ID=$(docker compose ps -q civicrm)


if [ -d "./config" ]; then
  docker cp -q "./config/" "${CONTAINER_ID}:/tmp/config"
  for config_dir in ./config/*; do
    if [ -d "$config_dir" ]; then
      app_name=$(basename "$config_dir")
      docker exec -u0 "${CONTAINER_ID}" mkdir -p /srv/config/exposed/"$app_name"
      docker exec -u0 "${CONTAINER_ID}" cp -r /tmp/config/"$app_name"/. /srv/config/exposed/"$app_name"/
      docker exec -u0 "${CONTAINER_ID}" chown -R "${FR_DOCKER_UID}":"${FR_DOCKER_GID}" /srv/config/exposed/"$app_name"
    fi
  done
  docker exec -u0 "${CONTAINER_ID}" rm -rf /tmp/config
  echo "local => container: sync complete - ./config/*:/srv/config/exposed/"
else
  echo "Directory not found: ./config"
fi

if [ -d "./config-private" ]; then
  docker cp -q "./config-private/" "${CONTAINER_ID}:/tmp/config-private"
  for config_private_dir in ./config-private/*; do
    if [ -d "$config_private_dir" ]; then
      app_private_name=$(basename "$config_private_dir")
      docker exec -u0 "${CONTAINER_ID}" mkdir -p /srv/config/private/"$app_private_name"
      docker exec -u0 "${CONTAINER_ID}" cp -r /tmp/config-private/"$app_private_name"/. /srv/config/private/"$app_private_name"/
      docker exec -u0 "${CONTAINER_ID}" chown -R "${FR_DOCKER_UID}":"${FR_DOCKER_GID}" /srv/config/private/"$app_private_name"
    fi
  done
  docker exec -u0 "${CONTAINER_ID}" rm -rf /tmp/config-private
  echo "local => container: sync complete - ./config-private/*:/srv/config/private/"
else
  echo "Directory not found: ./config-private"
fi
