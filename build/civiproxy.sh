# Civiproxy Config
CIVIPROXY_SERVICE_NAME="civiproxy"
CIVIPROXY_SRC_DIR="src/civiproxy"

echo
echo "**** Clone Civiproxy"
# clone and configure git repos
if $(ask_reclone $CIVIPROXY_SRC_DIR "Civiproxy wiki repo"); then

  rm -rf "${CIVIPROXY_SRC_DIR:?}"/*
  find "${CIVIPROXY_SRC_DIR:?}" -mindepth 1 -name '.*' -exec rm -rf {} +

  # Clone Civiproxy with gerrit hooks
  git clone "ssh://${GIT_REVIEW_USER}@gerrit.wikimedia.org:29418/wikimedia/fundraising/crm/civiproxy" \
    $CIVIPROXY_SRC_DIR &&
    (
      cd "$CIVIPROXY_SRC_DIR" &&
        mkdir -p $(git rev-parse --git-dir)/hooks/ &&
        curl -Lo $(git rev-parse --git-dir)/hooks/commit-msg \
          https://gerrit.wikimedia.org/r/tools/hooks/commit-msg
      chmod +x $(git rev-parse --git-dir)/hooks/commit-msg
    )
fi

# bring up docker container
docker_compose_up "$DOCKER_COMPOSE_FILE" "$CIVIPROXY_SERVICE_NAME"

