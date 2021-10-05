#!/bin/bash

# Script to set up fundraising development environment
source .env
if [ -z "$FR_DOCKER_PAYMENTS_TEST_NUMBER" ] || [ -z "$FR_DOCKER_PAYMENTS_HTTP_PORT" ]; then
  echo "Please run setup.sh and choose a test server number and a payments HTTP port";
  exit 1
fi;
REMOTE_PORT=$((8000 + FR_DOCKER_PAYMENTS_TEST_NUMBER))
echo "ssh -o ExitOnForwardFailure=yes -fN -R $REMOTE_PORT:localhost:$FR_DOCKER_PAYMENTS_HTTP_PORT payments.fr-tech-dev"
ssh -o ExitOnForwardFailure=yes -fN -R $REMOTE_PORT:localhost:$FR_DOCKER_PAYMENTS_HTTP_PORT payments.fr-tech-dev && \
  echo "https://paymentstest$FR_DOCKER_PAYMENTS_TEST_NUMBER.wmcloud.org should forward to localhost.";
echo
