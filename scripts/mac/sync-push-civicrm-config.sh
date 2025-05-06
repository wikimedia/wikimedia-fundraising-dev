#!/bin/bash
CONTAINER_ID=civicrm


if [ -d "./config" ]; then
  docker compose cp "./config/" "${CONTAINER_ID}:/tmp/"
  for config_dir in ./config/*; do
    if [ -d "$config_dir" ]; then
      app_name=$(basename "$config_dir")
      docker compose exec "${CONTAINER_ID}" mkdir -p /srv/config/exposed/"$app_name"
      docker compose exec "${CONTAINER_ID}" cp -r /tmp/config/"$app_name"/. /srv/config/exposed/"$app_name"/
    fi
  done
  echo "local => container: sync complete - ./config/*:/srv/config/exposed/"
else
  echo "Directory not found: ./config"
fi

if [ -d "./config-private" ]; then
  docker compose cp "./config-private/" "${CONTAINER_ID}:/tmp/"
  for config_private_dir in ./config-private/*; do
    if [ -d "$config_private_dir" ]; then
      app_private_name=$(basename "$config_private_dir")
      docker compose exec "${CONTAINER_ID}" mkdir -p /srv/config/private/"$app_private_name"
      docker compose exec "${CONTAINER_ID}" cp -r /tmp/config-private/"$app_private_name"/. /srv/config/private/"$app_private_name"/
    fi
  done
  docker compose exec "${CONTAINER_ID}" rm -rf /tmp/config-private
  echo "local => container: sync complete - ./config-private/*:/srv/config/private/"
else
  echo "Directory not found: ./config-private"
fi
