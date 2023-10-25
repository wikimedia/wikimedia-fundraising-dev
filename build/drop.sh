echo "**** Removing Docker containers"
read -p "Please confirm you also want to drop volume mounts? (MySQL, Redis, PrivateBin) [yN] " -r
if [[ $REPLY =~ ^[Yy]$ ]]; then
  docker compose down -v
else
  docker compose down
fi
echo