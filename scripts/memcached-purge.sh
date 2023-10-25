#!/bin/bash
# Clears contents of memcached

# We run this on the payments container for two reasons:
# - nc is installed there.
# - It's better not to run on the host machine, since we don't know if nc is
#   installed locally, and it's easiest to access the memcached server from
#   within the docker network.
docker compose exec -T payments bash -c 'echo flush_all | nc -q 1 memcached 11211'
