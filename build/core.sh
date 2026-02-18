# Core Config
CORE_SERVICE_NAME="core"
CORE_CONTAINER_DIR="/var/www/html"
CORE_SRC_DIR="src/core"
CORE_TMP_DIR="/tmp/idea_backups/${CORE_SERVICE_NAME}"
MW_CORE_BRANCH="${MW_CORE_BRANCH:-master}"
MW_LANG="en"
MW_USER="admin"
MW_PASSWORD="dockerpass"

if [ "$CORE_PORT" = "" ]; then
  CORE_PORT=9013
  echo "CORE_PORT=9013" >> .env
fi
if [ "$CORE_HTTP_PORT" = "" ]; then
  CORE_HTTP_PORT=9014
  echo "CORE_HTTP_PORT=9014" >> .env
fi

echo
echo "**** Clone Core wiki"
# clone and configure git repos
if $(ask_reclone $CORE_SRC_DIR "Core wiki repo"); then

  # Backup the .idea directory if it exists
  if [ -d "${CORE_SRC_DIR}/.idea" ]; then
    mkdir -p "$CORE_TMP_DIR"
    mv "${CORE_SRC_DIR}/.idea" "$CORE_TMP_DIR"
    echo "* $CORE_SRC_DIR/.idea backed up"
    echo
  fi

  rm -rf "${CORE_SRC_DIR:?}"/*
  find "${CORE_SRC_DIR:?}" -mindepth 1 -name '.*' -exec rm -rf {} +

  # Clone core with gerrit hooks
  git clone "ssh://${GIT_REVIEW_USER}@gerrit.wikimedia.org:29418/mediawiki/core" \
    --depth=10 --no-single-branch \
    $CORE_SRC_DIR &&
    (
      cd "$CORE_SRC_DIR" &&
        mkdir -p $(git rev-parse --git-dir)/hooks/ &&
        curl -Lo $(git rev-parse --git-dir)/hooks/commit-msg \
          https://gerrit.wikimedia.org/r/tools/hooks/commit-msg
      chmod +x $(git rev-parse --git-dir)/hooks/commit-msg
    )

  pushd $CORE_SRC_DIR
    git checkout ${MW_CORE_BRANCH}
    git submodule update --init --recursive
  popd

  # Clone Vector skin (not bundled as a submodule on master)
  git clone "ssh://${GIT_REVIEW_USER}@gerrit.wikimedia.org:29418/mediawiki/skins/Vector" \
    --depth=10 --no-single-branch \
    ${CORE_SRC_DIR}/skins/Vector &&
    (
      cd "${CORE_SRC_DIR}/skins/Vector" &&
        mkdir -p $(git rev-parse --git-dir)/hooks/ &&
        curl -Lo $(git rev-parse --git-dir)/hooks/commit-msg \
          https://gerrit.wikimedia.org/r/tools/hooks/commit-msg
      chmod +x $(git rev-parse --git-dir)/hooks/commit-msg
    )

  # Clone FundraisingWidgets extension
  git clone https://github.com/jackgleeson/mediawiki-extensions-FundraisingWidgets \
    --depth=10 \
    ${CORE_SRC_DIR}/extensions/FundraisingWidgets

  # Restore the .idea directory if it was backed up
  if [ -d "$CORE_TMP_DIR/.idea" ]; then
    mv "$CORE_TMP_DIR/.idea" "${CORE_SRC_DIR}/"
    rmdir "$CORE_TMP_DIR"
    echo
    echo "* $CORE_SRC_DIR/.idea restored"
    echo
  fi

fi

# bring up docker container
docker_compose_up "$DOCKER_COMPOSE_FILE"  "$CORE_SERVICE_NAME"

echo "**** Install Core wiki "

# Composer install
read -p "Run Core wiki Composer install? [yN] " -r
if [[ $REPLY =~ ^[Yy]$ ]]; then
  $DOCKER_COMPOSE_COMMAND_BASE exec -w ${CORE_CONTAINER_DIR} ${CORE_SERVICE_NAME} composer install
fi
echo

core_install=true
localsettings_fn=${CORE_SRC_DIR}/LocalSettings.php
# Prepare customized LocalSettings.php
cat <<EOF >/tmp/LocalSettings.php
<?php
require( '/srv/config/exposed/core/LocalSettings.php');
EOF

if [[ -e $localsettings_fn ]]; then
  read -p "Set up a fresh Core wiki LocalSettings.php? [yN] " -r
  echo
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    # Back up LocalSettings.php if it's not the standard version
    if ! cmp -s $localsettings_fn /tmp/LocalSettings.php; then
      echo "LocalSettings.php contains customizations. Backing it up."
      backup $localsettings_fn
    fi
    rm $localsettings_fn
  else
    core_install=false
  fi
fi

read -p "Run Core wiki maintenance/install.php [yN] " -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
  $DOCKER_COMPOSE_COMMAND_BASE exec -w ${CORE_CONTAINER_DIR} ${CORE_SERVICE_NAME} php maintenance/install.php \
    --server https://localhost:${CORE_PORT} \
    --dbname=core \
    --dbuser=root \
    --dbserver=database \
    --lang=${MW_LANG} \
    --scriptpath="" \
    --pass=${MW_PASSWORD} Core ${MW_USER}

  echo "Writing $localsettings_fn"
  mv /tmp/LocalSettings.php $localsettings_fn
  echo
fi

core_update=true

# Only ask about running update.php if we didn't run install.php; otherwise we have to run it.
if [ $core_install = false ]; then
  read -p "Run Core wiki maintenance/update.php? [yN] " -r
  echo
  if ! [[ $REPLY =~ ^[Yy]$ ]]; then
    core_update=false
  fi
fi

if [ $core_update = true ]; then
  $DOCKER_COMPOSE_COMMAND_BASE exec -w "/var/www/html/" ${CORE_SERVICE_NAME} php maintenance/update.php --quick
fi
echo

echo "Core Wiki URL: https://localhost:$CORE_PORT"
