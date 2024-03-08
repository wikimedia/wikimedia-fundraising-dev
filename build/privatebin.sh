# PrivateBin Config
PRIVATEBIN_SERVICE_NAME="privatebin"
PRIVATEBIN_SRC_DIR="src/privatebin"
PRIVATEBIN_CONTAINER_DIR="/var/www/html"

echo
echo "**** Clone PrivateBin"
# clone and configure git repos
if $(ask_reclone $PRIVATEBIN_SRC_DIR "Privatebin repo"); then

  rm -rf "${PRIVATEBIN_SRC_DIR:?}"/*
  find "${PRIVATEBIN_SRC_DIR:?}" -mindepth 1 -name '.*' -exec rm -rf {} +

  # Clone PrivateBin with gerrit hooks
  git clone "ssh://${GIT_REVIEW_USER}@gerrit.wikimedia.org:29418/wikimedia/fundraising/privatebin" \
    $PRIVATEBIN_SRC_DIR &&
    (
      cd "$PRIVATEBIN_SRC_DIR" &&
        mkdir -p $(git rev-parse --git-dir)/hooks/ &&
        curl -Lo $(git rev-parse --git-dir)/hooks/commit-msg \
          https://gerrit.wikimedia.org/r/tools/hooks/commit-msg
      chmod +x $(git rev-parse --git-dir)/hooks/commit-msg
    )
fi

# bring up docker container
docker_compose_up "$DOCKER_COMPOSE_FILE" "$PRIVATEBIN_SERVICE_NAME"

# Composer install
read -p "Run PrivateBin Composer install? [yN] " -r
if [[ $REPLY =~ ^[Yy]$ ]]; then
  $DOCKER_COMPOSE_COMMAND_BASE exec -w ${PRIVATEBIN_CONTAINER_DIR} ${PRIVATEBIN_SERVICE_NAME} composer install
fi
echo

