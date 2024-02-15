# Payments Config
PAYMENTS_SERVICE_NAME="payments"
PAYMENTS_CONTAINER_DIR="/var/www/html"
PAYMENTS_SRC_DIR="src/payments"
DONATION_INTERFACE_EXT_DIR="$PAYMENTS_SRC_DIR/extensions/DonationInterface"
FUNDRAISING_EMAIL_UNSUBSCRIBE_EXT_DIR="$PAYMENTS_SRC_DIR/extensions/FundraisingEmailUnsubscribe"
MW_CORE_BRANCH="fundraising/REL1_39"
MW_LANG="en"
MW_USER="admin"
MW_PASSWORD="dockerpass"

echo
echo "**** Clone Payments-wiki"
# clone and configure git repos
if $(ask_reclone $PAYMENTS_SRC_DIR "Payments wiki repo"); then
  #    check for .idea file to preserve phpstorm config and xdebug setup
  rm -rf $PAYMENTS_SRC_DIR

  # Clone payments with gerrit hooks
  git clone "ssh://${GIT_REVIEW_USER}@gerrit.wikimedia.org:29418/mediawiki/core" \
    --depth=10 --no-single-branch \
    $PAYMENTS_SRC_DIR &&
    (
      cd "$PAYMENTS_SRC_DIR" &&
        mkdir -p $(git rev-parse --git-dir)/hooks/ &&
        curl -Lo $(git rev-parse --git-dir)/hooks/commit-msg \
          https://gerrit.wikimedia.org/r/tools/hooks/commit-msg
      chmod +x $(git rev-parse --git-dir)/hooks/commit-msg
    )

  pushd $PAYMENTS_SRC_DIR
    git checkout --track remotes/origin/${MW_CORE_BRANCH}
    git submodule update --init --recursive
  popd

  pushd $DONATION_INTERFACE_EXT_DIR
    git checkout master
  popd

  pushd $FUNDRAISING_EMAIL_UNSUBSCRIBE_EXT_DIR
    git checkout master
  popd
fi

# bring up docker container
docker_compose_up "$DOCKER_COMPOSE_FILE"  "$PAYMENTS_SERVICE_NAME"

echo "**** Install Payments-wiki "

# Composer install
read -p "Run Payments-wiki Composer install? [yN] " -r
if [[ $REPLY =~ ^[Yy]$ ]]; then
  $DOCKER_COMPOSE_COMMAND_BASE exec -w ${PAYMENTS_CONTAINER_DIR} ${PAYMENTS_SERVICE_NAME} composer install
fi
echo

payments_install=true
localsettings_fn=${PAYMENTS_SRC_DIR}/LocalSettings.php
# Prepare customized LocalSettings.php
cat <<EOF >/tmp/LocalSettings.php
<?php
require( '/srv/config/exposed/payments/LocalSettings.php');
EOF

if [[ -e $localsettings_fn ]]; then
  read -p "Set up a fresh Payments-wiki LocalSettings.php? [yN] " -r
  echo
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    # Back up LocalSettings.php if it's not the standard version
    if ! cmp -s $localsettings_fn /tmp/LocalSettings.php; then
      echo "LocalSettings.php contains customizations. Backing it up."
      backup $localsettings_fn
    fi
    rm $localsettings_fn
  else
    payments_install=false
  fi
fi

read -p "Run Payments-wiki maintenance/install.php [yN] " -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
  $DOCKER_COMPOSE_COMMAND_BASE exec -w ${PAYMENTS_CONTAINER_DIR} ${PAYMENTS_SERVICE_NAME} php maintenance/install.php \
    --server https://localhost:${PAYMENTS_PORT} \
    --dbname=payments \
    --dbuser=root \
    --dbserver=database \
    --lang=${MW_LANG} \
    --scriptpath="" \
    --pass=${MW_PASSWORD} Payments ${MW_USER}

  echo "Writing $localsettings_fn"
  mv /tmp/LocalSettings.php $localsettings_fn
  echo
fi

payments_update=true

# Only ask about running update.php if we didn't run install.php; otherwise we have to run it.
if [ $payments_install = false ]; then
  read -p "Run Payments-wiki maintenance/update.php? [yN] " -r
  echo
  if ! [[ $REPLY =~ ^[Yy]$ ]]; then
    payments_update=false
  fi
fi

if [ $payments_update = true ]; then
  $DOCKER_COMPOSE_COMMAND_BASE exec -w "/var/www/html/" payments php maintenance/update.php --quick
fi
echo

read -p "Update Payments wiki text? [yN] " -r
if [[ $REPLY =~ ^[Yy]$ ]]; then
  ./scripts/payments-update-text.sh
fi
echo

echo "Payments HTTPS URL: https://localhost:$PAYMENTS_PORT"
echo "Payments HTTP URL: http://localhost:$PAYMENTS_HTTP_PORT"
echo "Payments Test URL: https://paymentstest$PROXY_FORWARD_ID.wmcloud.org (see README.md)"
