#!/bin/bash
echo "Dropping and recreating silverpop database..."
docker compose exec database mysql -u root -e "DROP DATABASE IF EXISTS silverpop; CREATE DATABASE silverpop;"
echo "Done."
