echo "**** Removing Docker containers"
read -p "Please confirm you also want to drop volume mounts? (MySQL, Redis, PrivateBin, Mac-specific mounts) [yN] " -r
if [[ $REPLY =~ ^[Yy]$ ]]; then
  $DOCKER_COMPOSE_COMMAND_BASE down -v
else
  $DOCKER_COMPOSE_COMMAND_BASE down
fi
echo
