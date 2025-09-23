# CiviCRM Standalone Config with WMF extensions
CIVICRM_SERVICE_NAME="civicrm"
CIVICRM_SRC_ENV_VARS="src/civi-sites/wmf.sh"
CIVICRM_SRC_DIR="src/civi-sites/wmf"
CIVI_ADMIN_PASS="admin"

echo "**** Clone CiviCRM"
if $(ask_reclone "${CIVICRM_SRC_DIR}" "Clone CiviCRM WMF (our version)"); then

  # Backup the .idea directory if it exists
  if [ -d "${CIVICRM_SRC_DIR}/.idea" ]; then
    mkdir -p "$CIVICRM_TMP_DIR"
    mv "${CIVICRM_SRC_DIR}/.idea" "$CIVICRM_TMP_DIR"
    echo "* $CIVICRM_SRC_DIR/.idea backed up"
    echo
  fi

  rm -rf "${CIVICRM_SRC_DIR:?}"/*
  find "${CIVICRM_SRC_DIR:?}" -mindepth 1 -name '.*' -exec rm -rf {} +

  rm -rf "${CIVICRM_SRC_DIR:?}"/*
  find "${CIVICRM_SRC_DIR:?}" -mindepth 1 -name '.*' -exec rm -rf {} +
  mkdir -p src/civi-sites

  git clone "ssh://${GIT_REVIEW_USER}@gerrit.wikimedia.org:29418/wikimedia/fundraising/crm" \
    ${CIVICRM_SRC_DIR} && \
    (cd "$CIVICRM_SRC_DIR" && \
    mkdir -p `git rev-parse --git-dir`/hooks/ && \
    curl -Lo `git rev-parse --git-dir`/hooks/commit-msg \
    https://gerrit.wikimedia.org/r/tools/hooks/commit-msg; \
    chmod +x `git rev-parse --git-dir`/hooks/commit-msg)

  pushd ${CIVICRM_SRC_DIR}
  git submodule update --init --recursive
  popd

  # Restore the .idea directory if it was backed up
  if [ -d "$CIVICRM_TMP_DIR/.idea" ]; then
    mv "$CIVICRM_TMP_DIR/.idea" "${CIVICRM_SRC_DIR}/"
    rmdir "$CIVICRM_TMP_DIR"
    echo
    echo "* $CIVICRM_SRC_DIR/.idea restored"
    echo
  fi

  echo
fi

# Composer install
read -p "Run CiviCRM Composer install? [yN] " -r
if [[ $REPLY =~ ^[Yy]$ ]]; then
  $DOCKER_COMPOSE_COMMAND_BASE exec -w /srv/civi-sites/wmf/ civicrm composer install
fi
echo

read -p "Install CiviCRM Standalone with WMF extensions [Yn] " -r
echo
if [[ ! $REPLY =~ ^[Nn]$ ]]; then

  rm -f "${CIVICRM_SRC_ENV_VARS:?}"
  mkdir -p src/civi-sites

  if [ "$USE_MAC_CONFIG" = "true" ]; then
    echo
    echo "**** MacOS Setup: sync local config to container"
    echo
    source "$MAC_SCRIPTS_DIR/sync-push-civicrm-config.sh"
  fi

	# Link config/civicrm/civibuild.conf to required location under buildkit source
	$DOCKER_COMPOSE_COMMAND_BASE exec civicrm ln -fs /srv/config/exposed/civicrm/civibuild.conf /srv/civicrm-buildkit/app/civibuild.conf
	echo

  echo "Running civibuild create"
  $DOCKER_COMPOSE_COMMAND_BASE exec -w "/srv/civi-sites/" ${CIVICRM_SERVICE_NAME} civibuild create wmf --admin-pass $CIVI_ADMIN_PASS
  echo

  $DOCKER_COMPOSE_COMMAND_BASE restart "$CIVICRM_SERVICE_NAME"


  if [ "$USE_MAC_CONFIG" = "true" ]; then
    echo
    echo "**** MacOS Setup: sync container source code to local to retain generated build config"
    echo
    source "$MAC_SCRIPTS_DIR/sync-pull-civicrm-standalone.sh"
    source "$MAC_SCRIPTS_DIR/sync-pull-civicrm-wmf.sh"
  fi

  echo "CiviCRM Standalone Installed!"

  echo
  echo "**** Backing up CiviCRM Standalone databases"
  $DOCKER_COMPOSE_COMMAND_BASE exec -T $CIVICRM_SERVICE_NAME mysqldump -hdatabase -uroot civicrm > ./.backup/sql/civicrm.sql
  echo "civicrm.sql added to .backup/sql"
  $DOCKER_COMPOSE_COMMAND_BASE exec -T $CIVICRM_SERVICE_NAME mysqldump -hdatabase -uroot civitest > ./.backup/sql/civitest.sql
  echo "wmftest.sql added to .backup/sql"
  echo
  echo "**** CiviCRM Standalone databases backed up! Restore them anytime with ./scripts/db/restore-civicrm-wmf.sh"
  echo
fi


if [ -f "$HOME/.gitconfig" ]; then
  echo "**** Git Config Copy: copying local .gitconfig to container. Makes life easier for folks who commit from the container!"
  $DOCKER_COMPOSE_COMMAND_BASE cp ~/.gitconfig civicrm:/home/docker/
  echo
fi

echo "CiviCRM-WMF URL: https://wmf.localhost:$CIVICRM_PORT/civicrm"
echo "CiviCRM-WMF user/password: admin/$CIVI_ADMIN_PASS"
