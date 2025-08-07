#!/bin/bash

docker compose exec -w "/srv/tools" -u root tools sh -c "
    # Run tox, and exit if it fails
    tox -r &&
    # If tox was successful, fix cache permissions
    chown -R \"\$FR_DOCKER_UID\":\"\$FR_DOCKER_GID\" /srv/tools
"
