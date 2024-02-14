echo "**** Removing Docker containers"
read -p "Please confirm you also want to drop volume mounts? (MySQL, Redis, PrivateBin, Mac-specific mounts) [yN] " -r
if [[ $REPLY =~ ^[Yy]$ ]]; then
  docker compose -f $DOCKER_COMPOSE_FILE down -v
else
  docker compose -f $DOCKER_COMPOSE_FILE down
fi
echo