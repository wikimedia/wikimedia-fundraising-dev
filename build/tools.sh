# Tools Config
TOOLS_SRC_DIR="src/tools"
TOOLS_SERVICE_NAME="tools"
DB_SERVICE_NAME="database"

echo
echo "**** Clone Fundraising Tools (Silverpop Export)"
clone_tools=$(ask_reclone "${TOOLS_SRC_DIR}" "Fundraising Tools repo")
if [ $clone_tools = true ]; then
  echo "**** Cloning and setting up WMF tools repo in src/${TOOLS_SRC_DIR}"

  rm -rf "${TOOLS_SRC_DIR:?}"/*
  find "${TOOLS_SRC_DIR:?}" -mindepth 1 -name '.*' -exec rm -rf {} +

  git clone "ssh://${GIT_REVIEW_USER}@gerrit.wikimedia.org:29418/wikimedia/fundraising/tools" \
    ${TOOLS_SRC_DIR} && \
    (cd "$TOOLS_SRC_DIR" && \
    mkdir -p `git rev-parse --git-dir`/hooks/ && \
    curl -Lo `git rev-parse --git-dir`/hooks/commit-msg \
    https://gerrit.wikimedia.org/r/tools/hooks/commit-msg; \
    chmod +x `git rev-parse --git-dir`/hooks/commit-msg)
fi

echo
echo "**** Set up default Silverpop config"
pushd src/tools/silverpop_export
cp silverpop_export.yaml.example  silverpop_export.yaml
popd
echo

# spin up the docker container
docker_compose_up "$DOCKER_COMPOSE_FILE" "$TOOLS_SERVICE_NAME"

# create required mysql databases
read -p "Create Silverpop & Silverpop test databases? [yN] " -r
if [[ $REPLY =~ ^[Yy]$ ]]; then
	# Create SQL script
	cat << EOF > /tmp/tools_setup.sql
CREATE DATABASE IF NOT EXISTS test;
CREATE USER IF NOT EXISTS 'test'@'%';
GRANT ALL PRIVILEGES ON test.* TO 'test'@'%';
CREATE DATABASE IF NOT EXISTS silverpop;
EOF
  $DOCKER_COMPOSE_COMMAND_BASE exec -T ${DB_SERVICE_NAME} mysql < /tmp/tools_setup.sql
fi
echo
echo "**** Fundraising Tools (Silverpop Export) setup complete"
echo
echo "Tools has a handful of useful scripts for commonly used "
echo "Silverpop Update script: ./scripts/silverpop-update.sh"
echo "Silverpop Export script: ./scripts/silverpop-export.sh"
echo "Tox script: ./scripts/tools-tox.sh (Python build & test tool)"
