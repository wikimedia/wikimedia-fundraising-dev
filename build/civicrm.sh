# CiviCRM Config
CIVICRM_SERVICE_NAME="civicrm"
CIVICRM_SRC_DIR="src/civi-sites/wmff"
CIVI_ADMIN_PASS="admin"

echo "**** Clone CiviCRM"
if $(ask_reclone "${CIVICRM_SRC_DIR}" "Clone CiviCRM WMFF (our version)"); then
  rm -rf ${CIVICRM_SRC_DIR}
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
	docker compose exec civicrm ln -fs /srv/config/exposed/civicrm/civibuild.conf /srv/civicrm-buildkit/app/civibuild.conf
	echo

	docker compose exec -w "/srv/civi-sites/" ${CIVICRM_SERVICE_NAME} civibuild create \
		wmff --admin-pass $CIVI_ADMIN_PASS

  docker compose restart "$CIVICRM_SERVICE_NAME"

  if [ "$USE_MAC_CONFIG" = "true" ]; then
    echo
    echo "**** MacOS Setup: sync container source code to local to retain generated build config"
    echo
    source "$MAC_SCRIPTS_DIR/sync-pull-civicrm.sh"
  fi

  echo
  echo "CiviCRM WMFF Installed!"
fi

echo "CiviCRM WMFF URL: https://wmff.localhost:$CIVICRM_PORT/civicrm"
echo "Civicrm WMFF user/password: admin/$CIVI_ADMIN_PASS"
