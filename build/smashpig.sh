# Smashpig Config
SMASHPIG_SERVICE_NAME="smashpig"
DATABASE_SERVICE_NAME="database"
SMASHPIG_CONTAINER_DIR="/srv/smashpig"
SMASHPIG_SRC_DIR="src/smashpig"
SMASHPIG_DB_USER_PASSWORD="dockerpass"

echo
echo "**** Clone Smashpig"
# clone and configure git repos
if $(ask_reclone $SMASHPIG_SRC_DIR "Smashpig repo"); then
  #    check for .idea file to preserve phpstorm config and xdebug setup
  rm -rf $SMASHPIG_SRC_DIR

  # Clone Smashpig with gerrit hooks
  git clone "ssh://${GIT_REVIEW_USER}@gerrit.wikimedia.org:29418/wikimedia/fundraising/SmashPig" \
    $SMASHPIG_SRC_DIR &&
    (
      cd "$SMASHPIG_SRC_DIR" &&
        mkdir -p $(git rev-parse --git-dir)/hooks/ &&
        curl -Lo $(git rev-parse --git-dir)/hooks/commit-msg \
          https://gerrit.wikimedia.org/r/tools/hooks/commit-msg
      chmod +x $(git rev-parse --git-dir)/hooks/commit-msg
    )
fi

# bring up docker container
docker_compose_up "$DOCKER_COMPOSE_FILE" "$SMASHPIG_SERVICE_NAME"

echo
echo "**** Install Smashpig"
# Composer install
read -p "Run Smashpig Composer install? [yN] " -r
if [[ $REPLY =~ ^[Yy]$ ]]; then
  $DOCKER_COMPOSE_COMMAND_BASE exec -w ${SMASHPIG_CONTAINER_DIR} ${SMASHPIG_SERVICE_NAME} composer install
fi
echo

echo "**** Smashpig Database Setup"

read -p "Create Smashpig database and db user? [yN] " -r
echo

if [[ $REPLY =~ ^[Yy]$ ]]; then

  # Create SQL script
  cat <<EOF >/tmp/smashpig_setup.sql
CREATE DATABASE IF NOT EXISTS smashpig;
use smashpig;
EOF

  cat src/smashpig/Schema/mysql/00[127]*.sql >>/tmp/smashpig_setup.sql

  cat <<EOF >>/tmp/smashpig_setup.sql
CREATE USER IF NOT EXISTS 'smashpig'@'localhost' IDENTIFIED BY '$SMASHPIG_DB_USER_PASSWORD';
CREATE USER IF NOT EXISTS 'smashpig'@'%' IDENTIFIED BY '$SMASHPIG_DB_USER_PASSWORD';
GRANT ALL PRIVILEGES ON smashpig.* To 'smashpig'@'localhost';
GRANT ALL PRIVILEGES ON smashpig.* To 'smashpig'@'%';
EOF

  $DOCKER_COMPOSE_COMMAND_BASE exec -T ${DATABASE_SERVICE_NAME} mysql </tmp/smashpig_setup.sql

  echo
fi
echo "**** Smashpig Setup complete"
echo "SmashPig IPN listener Test URL: https://paymentsipntest$PROXY_FORWARD_ID.wmcloud.org (see README.md)"
