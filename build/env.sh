#!/bin/bash

init_env() {
  if [[ -e .env ]]; then
    source .env
  else
    echo "DOCKER_HOST_OS=$(uname)" >> .env
    echo "FR_DOCKER_UID=$(id -u)" >> .env
    echo "FR_DOCKER_GID=$(id -g)" >> .env
    cat "$SETUP_DIR/ports.sh" >> .env
    source .env
    echo ".env file created with defaults."
  fi
}


update_env() {
  key="$1"
  value="$2"

  if [[ ! -e .env ]]; then
    echo ".env file does not exist. Creating one."
    init_env
  fi

  sed -i'.bk' "/^$key=/d" .env
  echo "$key=$value" >> .env
  echo "Updated $key=$value in .env."
}

show_env() {
  if [[ -e .env ]]; then
    cat .env
  else
    echo ".env file does not exist."
  fi
}
