# CiviCRM Config
CIVICRM_SERVICE_NAME="civicrm"
CIVICRM_SRC_CORE_DIR="src/civi-sites/dmaster"
CIVI_ADMIN_PASS="admin"

read -p "Install CiviCRM Core (for upstream testing)  [yN] " -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then

  rm -rf ${CIVICRM_SRC_CORE_DIR}
  mkdir -p src/civi-sites

	# Link config/civicrm/civibuild.conf to required location under buildkit source
	docker compose exec civicrm ln -fs /srv/config/exposed/civicrm/civibuild.conf /srv/civicrm-buildkit/app/civibuild.conf
	echo

  docker compose exec -w "/srv/civi-sites/" ${CIVICRM_SERVICE_NAME} civibuild create \
		dmaster --admin-pass $CIVI_ADMIN_PASS
  echo

  if [ "$USE_MAC_CONFIG" = "true" ]; then
    echo
    echo "**** MacOS Setup: sync container source code to local to retain generated build config"
    echo
    source "$MAC_SCRIPTS_DIR/sync-pull-civicrm-core.sh"
  fi

  echo "CiviCRM Core Installed!"
fi

echo "CiviCRM Core URL: https://dmaster.localhost:$CIVICRM_PORT/civicrm"
echo "Civicrm Core user/password: admin/$CIVI_ADMIN_PASS"