# CiviCRM Buildkit Config
CIVICRM_SERVICE_NAME="civicrm"
CIVICRM_BUILDKIT_SRC_DIR="src/civicrm-buildkit"

echo
echo "**** Clone CiviCRM Buildkit"
if $(ask_reclone "${CIVICRM_BUILDKIT_SRC_DIR}" "CiviCRM Buildkit repo"); then
    rm -rf ${CIVICRM_BUILDKIT_SRC_DIR}
    git clone "https://github.com/civicrm/civicrm-buildkit.git" ${CIVICRM_BUILDKIT_SRC_DIR}
    echo
fi

# spin up the docker container
docker_compose_up "$DOCKER_COMPOSE_FILE" "$CIVICRM_SERVICE_NAME"

if [ "$USE_MAC_CONFIG" = "true" ]; then
  echo
  echo "**** MacOS Setup: sync local buildkit to container"
  echo
  source "$MAC_SCRIPTS_DIR/sync-push-civicrm-buildkit.sh"
fi

echo
read -p "CiviCRM Buildkit: run composer install? [yN] " -r
if [[ $REPLY =~ ^[Yy]$ ]]; then
  # TODO put this in a separate script
  $DOCKER_COMPOSE_COMMAND_BASE exec -w "/srv/civicrm-buildkit" civicrm composer install
fi
echo

read -p "CiviCRM Buildkit: run npm install? [yN] " -r
if [[ $REPLY =~ ^[Yy]$ ]]; then
  # TODO put this in a separate script
  $DOCKER_COMPOSE_COMMAND_BASE exec -w "/srv/civicrm-buildkit" civicrm npm install
fi
echo

if [ "$USE_MAC_CONFIG" = "true" ]; then
  echo
  echo "**** MacOS Setup: sync container buildkit to local"
  echo
  source "$MAC_SCRIPTS_DIR/sync-pull-civicrm-buildkit.sh"
fi

echo "CiviCRM Buildkit Installed!"
echo
