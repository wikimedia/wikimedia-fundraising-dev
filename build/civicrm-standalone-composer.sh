# CiviCRM Standalone Config
CIVICRM_SERVICE_NAME="civicrm"
CIVICRM_SRC_CORE_ENV_VARS="src/civi-sites/standalone-composer.sh"
CIVICRM_SRC_CORE_DIR="src/civi-sites/standalone-composer"
CIVI_ADMIN_PASS="admin"

read -p "Install CiviCRM Standalone  [yN] " -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then

  rm -rf "${CIVICRM_SRC_CORE_DIR:?}"/*
  rm -f "${CIVICRM_SRC_CORE_ENV_VARS:?}"
  find "${CIVICRM_SRC_CORE_DIR:?}" -mindepth 1 -name '.*' -exec rm -rf {} +
  mkdir -p src/civi-sites

  if [ "$USE_MAC_CONFIG" = "true" ]; then
    echo
    echo "**** MacOS Setup: sync local config to container"
    echo
    source "$MAC_SCRIPTS_DIR/sync-push-civicrm-config.sh"
  fi

	# Link config/civicrm/civibuild.conf to required location under buildkit source
	$DOCKER_COMPOSE_COMMAND_BASE exec civicrm ln -fs /srv/config/exposed/civicrm/civibuild-standalone.conf /srv/civicrm-buildkit/app/civibuild.conf
	echo

  $DOCKER_COMPOSE_COMMAND_BASE exec -w "/srv/civi-sites/" ${CIVICRM_SERVICE_NAME} civibuild create standalone-composer --admin-pass $CIVI_ADMIN_PASS
  echo

  $DOCKER_COMPOSE_COMMAND_BASE restart "$CIVICRM_SERVICE_NAME"


  if [ "$USE_MAC_CONFIG" = "true" ]; then
    echo
    echo "**** MacOS Setup: sync container source code to local to retain generated build config"
    echo
    source "$MAC_SCRIPTS_DIR/sync-pull-civicrm-standalone.sh"
  fi

  echo "CiviCRM Standalone Installed!"

  echo
  echo "**** Backing up CiviCRM Standalone databases"
  $DOCKER_COMPOSE_COMMAND_BASE exec -T $CIVICRM_SERVICE_NAME mysqldump -hdatabase -uroot standalonedev_civi > ./.backup/sql/standalone_civicrm_backup.sql
  echo "standalone_civicrm_backup.sql added to .backup/sql"
  $DOCKER_COMPOSE_COMMAND_BASE exec -T $CIVICRM_SERVICE_NAME mysqldump -hdatabase -uroot standalonedev_test > ./.backup/sql/standalone_test_backup.sql
  echo "standalone_test_backup.sql added to .backup/sql"
  echo
  echo "**** CiviCRM Standalone databases backed up! Restore them anytime with ./scripts/db/restore-civicrm-standalone.sh"
  echo
fi


if [ -f "$HOME/.gitconfig" ]; then
  echo "**** Git Config Copy: copying local .gitconfig to container. Makes life easier for folks who commit from the container!"
  $DOCKER_COMPOSE_COMMAND_BASE cp ~/.gitconfig civicrm:/home/docker/
  echo
fi

echo "CiviCRM Core URL: https://standalone-composer.localhost:$CIVICRM_PORT/civicrm"
echo "Civicrm Core user/password: admin/$CIVI_ADMIN_PASS"
