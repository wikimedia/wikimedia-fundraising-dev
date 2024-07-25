# CiviCRM Config
CIVICRM_SERVICE_NAME="civicrm"
CIVICRM_SRC_DIR="src/civi-sites/wmff"
CIVI_ADMIN_PASS="admin"
CIVICRM_TMP_DIR="/tmp/idea_backups/${CIVICRM_SERVICE_NAME}"

echo "**** Clone CiviCRM"
if $(ask_reclone "${CIVICRM_SRC_DIR}" "Clone CiviCRM WMFF (our version)"); then

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

read -p "Install CiviCRM WMFF (our version) [yN] " -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then

  if [ "$USE_MAC_CONFIG" = "true" ]; then
    echo
    echo "**** MacOS Setup: sync local source code and config to container"
    echo
    source "$MAC_SCRIPTS_DIR/sync-push-civicrm-config.sh"
    source "$MAC_SCRIPTS_DIR/sync-push-civicrm.sh"
  fi

	# Link config/civicrm/civibuild.conf to required location under buildkit source
	$DOCKER_COMPOSE_COMMAND_BASE exec civicrm ln -fs /srv/config/exposed/civicrm/civibuild.conf /srv/civicrm-buildkit/app/civibuild.conf
	echo

	$DOCKER_COMPOSE_COMMAND_BASE exec -w "/srv/civi-sites/" ${CIVICRM_SERVICE_NAME} civibuild create \
		wmff --admin-pass $CIVI_ADMIN_PASS

  $DOCKER_COMPOSE_COMMAND_BASE restart "$CIVICRM_SERVICE_NAME"

  if [ "$USE_MAC_CONFIG" = "true" ]; then
    echo
    echo "**** MacOS Setup: sync container source code to local to retain generated build config"
    echo
    source "$MAC_SCRIPTS_DIR/sync-pull-civicrm.sh"
  fi

  echo
  echo "CiviCRM WMFF Installed!"
  echo
  echo "**** Backing up CiviCRM WMFF databases"
  $DOCKER_COMPOSE_COMMAND_BASE exec -T $CIVICRM_SERVICE_NAME mysqldump -hdatabase -uroot civicrm > ./.backup/sql/wmff_civicrm_backup.sql
  echo "wmff_civicrm_backup.sql added to .backup/sql"
  $DOCKER_COMPOSE_COMMAND_BASE exec -T $CIVICRM_SERVICE_NAME mysqldump -hdatabase -uroot drupal > ./.backup/sql/wmff_drupal_backup.sql
  echo "wmff_drupal_backup.sql added to .backup/sql"
  $DOCKER_COMPOSE_COMMAND_BASE exec -T $CIVICRM_SERVICE_NAME mysqldump -hdatabase -uroot wmff_test > ./.backup/sql/wmff_test_backup.sql
  echo "wmff_test_backup.sql added to .backup/sql"
  echo
  echo "**** CiviCRM WMFF databases backed up! Restore them anytime with ./scripts/db/restore-civicrm.sh"
  echo


fi

echo "CiviCRM WMFF URL: https://wmff.localhost:$CIVICRM_PORT/civicrm"
echo "Civicrm WMFF user/password: admin/$CIVI_ADMIN_PASS"
