#!/bin/bash
# run tox
docker compose exec -w "/srv/tools" -u root tools tox
# fix cache permissions
docker compose exec -u root tools sh -c "chown -R \$FR_DOCKER_UID:\$FR_DOCKER_GID /srv/tools"