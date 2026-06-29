DATABASE_SERVICE_NAME="database"
FUNDRAISING_ML_SRC_DIR="src/fundraising-ml"
FUNDRAISING_ML_SERVICE_NAME="fundraising-ml"
ML_DB_USER_PASSWORD="dockerpass"

if [ "$FUNDRAISING_ML_PORT" = "" ]; then
  FUNDRAISING_ML_PORT=9012
  echo "FUNDRAISING_ML_PORT=9012" >> .env
fi

if [ "$FUNDRAISING_ML_DEBUG_PORT" = "" ]; then
  FUNDRAISING_ML_DEBUG_PORT=9016
  echo "FUNDRAISING_ML_DEBUG_PORT=9016" >> .env
fi

echo "**** Clone fundraising ML service"
clone_ml=$(ask_reclone "${FUNDRAISING_ML_SRC_DIR}" "Fundraising ML service repo")
if [ $clone_ml = true ]; then
  echo "**** Cloning and setting up Fundraising ML service repo in ${FUNDRAISING_ML_SRC_DIR}"

  rm -rf "${FUNDRAISING_ML_SRC_DIR:?}"/*
  find "${FUNDRAISING_ML_SRC_DIR:?}" -mindepth 1 -name '.*' -exec rm -rf {} +

  git clone "git@gitlab-ssh.wikimedia.org:repos/fundraising-tech/fundraising-ml.git" \
    ${FUNDRAISING_ML_SRC_DIR}
fi

$DOCKER_COMPOSE_COMMAND_BASE up --force-recreate -d "$FUNDRAISING_ML_SERVICE_NAME"

read -p "Create Fundraising ML database and db user? [yN] " -r
echo

if [[ $REPLY =~ ^[Yy]$ ]]; then

  # Create SQL script
  cat <<EOF >/tmp/fundraising_ml_setup.sql
CREATE DATABASE IF NOT EXISTS fundraising_ml;
USE fundraising_ml;
EOF

  cat src/fundraising-ml/sql/*sql >> /tmp/fundraising_ml_setup.sql

  cat <<EOF >>/tmp/fundraising_ml_setup.sql
CREATE USER IF NOT EXISTS 'fundraising_ml'@'localhost' IDENTIFIED BY '$ML_DB_USER_PASSWORD';
CREATE USER IF NOT EXISTS 'fundraising_ml'@'%' IDENTIFIED BY '$ML_DB_USER_PASSWORD';
GRANT ALL PRIVILEGES ON fundraising_ml.* To 'fundraising_ml'@'localhost';
GRANT ALL PRIVILEGES ON fundraising_ml.* To 'fundraising_ml'@'%';
EOF

  $DOCKER_COMPOSE_COMMAND_BASE exec -T ${DATABASE_SERVICE_NAME} mariadb </tmp/fundraising_ml_setup.sql

  echo
fi

echo
echo "**** Fundraising ML setup complete"
echo
echo "You can test it with curl --header 'Content-Type: application/json' -d '{\"ts\":\"2026-06-01 15:23\",\"contribution_tracking_id\":123,\"order_id\":123.1,\"amount_in_usd_cents\":1000,\"amount_in_minor_units\":1000,\"currency\":\"USD\",\"email\":\"testy@example.com\",\"country\":\"US\",\"utm_key\":\"boooo\"}' localhost:$FUNDRAISING_ML_PORT/v1/score"
