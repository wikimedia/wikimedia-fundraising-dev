# GR4VY Config
GR4VY_SRC_DIR="src/gr4vy"
GR4VY_SERVICE_NAME="gr4vy"

echo
echo "**** Clone Gr4vy Proof Of Concept Repo"
clone_GR4VY=$(ask_reclone "${GR4VY_SRC_DIR}" "Fundraising GR4VY repo")
if [ $clone_GR4VY = true ]; then
  echo "**** Cloning and setting up WMF GR4VY repo in src/${GR4VY_SRC_DIR}"

  rm -rf "${GR4VY_SRC_DIR:?}"/*
  find "${GR4VY_SRC_DIR:?}" -mindepth 1 -name '.*' -exec rm -rf {} +
  git clone https://github.com/jackgleeson/gr4vy-poc  ${GR4VY_SRC_DIR}
fi

docker_compose_up "$DOCKER_COMPOSE_FILE" "$GR4VY_SERVICE_NAME"

echo
read -p "Run Gr4vy POC Composer install? [yN] " -r
if [[ $REPLY =~ ^[Yy]$ ]]; then
  $DOCKER_COMPOSE_COMMAND_BASE exec -w /var/www/html ${GR4VY_SERVICE_NAME} composer install
fi
echo

echo
echo "**** GR4VY POC Repo setup complete"
echo
echo "GR4VY Sandbox console URL: https://sandbox.partners.gr4vy.app/sign-in"
echo
echo "GR4VY local embedded form URL: http://localhost:$GR4VY_PORT/embed.php"
