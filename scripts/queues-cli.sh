#!/bin/bash
# Turn off globbing so we can say "keys *"
set -f
docker compose exec queues redis-cli $@