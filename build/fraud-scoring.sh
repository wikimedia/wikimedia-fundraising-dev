FRAUD_SCORING_SRC_DIR="src/fraud-scoring"
FRAUD_SCORING_SERVICE_NAME="fraud-scoring"
if [ "$FRAUD_SCORING_PORT" = "" ]; then
  FRAUD_SCORING_PORT=9012
  echo "FRAUD_SCORING_PORT=9012" >> .env
fi

echo "**** Clone Fraud scoring service"
clone_fraud=$(ask_reclone "${FRAUD_SCORING_SRC_DIR}" "Fraud scoring service repo")
if [ $clone_fraud = true ]; then
  echo "**** Cloning and setting up Fraud scoring service repo in ${FRAUD_SCORING_SRC_DIR}"

  rm -rf "${FRAUD_SCORING_SRC_DIR:?}"/*
  find "${FRAUD_SCORING_SRC_DIR:?}" -mindepth 1 -name '.*' -exec rm -rf {} +

  git clone "git@gitlab.wikimedia.org:repos/fundraising-tech/fraud-scoring.git" \
    ${FRAUD_SCORING_SRC_DIR}
fi

$DOCKER_COMPOSE_COMMAND_BASE up --force-recreate -d "$FRAUD_SCORING_SERVICE_NAME"

echo
echo "**** Fraud scoring service setup complete"
echo
echo "You can test it with curl -d '{}' localhost:$FRAUD_SCORING_PORT/v1"
