#!/bin/bash

SETUP_DIR="./build"
SCRIPTS_DIR="./scripts"
DOCKER_COMPOSE_FILE="docker-compose.yml"
MAC_SCRIPTS_DIR="./scripts/mac"
MAC_DOCKER_COMPOSE_FILE="docker-compose-mac.yml"
USE_MAC_CONFIG="false"
SKIP_RECLONE="false"

display_help() {
  echo "Usage: $0 [OPTION]... [COMMAND]"
  echo "Fundraising-dev setup script."
  echo
  echo "  -h, --help               Display this help and exit"
  echo
  echo "========================= Setup Options ========================="
  echo "  --mac                    Use Mac-friendly Docker config (speed things up!)"
  echo "  --skip-reclone           Do not ask to reclone any repos"
  echo "  --full                   Set up everything!"
  echo "  --civicrm                Set up CiviCRM WMFF (our version)"
  echo "  --civicrm-core           Set up CiviCRM Core (for upstream testing)"
  echo "  --payments               Set up PaymentsWiki"
  echo "  --donut                  Set up Donate/Donut Wiki"
  echo "  --email-prefs            Set up Email-Preference Centre Wiki"
  echo "  --civiproxy              Set up CiviProxy (Email-Preference Centre Wiki)"
  echo "  --smashpig               Set up Smashpig Listeners (IPN testing)"
  echo "  --tools                  Set up Fundraising-tools (incl. Silverpop Export scripts)"
  echo "  --privatebin             Set up PrivateBin"
  echo
  echo "========================= Docker Commands ========================="
  echo "  up                       Start up Docker containers"
  echo "  down                     Stop and remove Docker containers"
  echo "  restart                  Restart Docker containers"
  echo "  status                   Show status of installed apps and bound ports"
  echo "  drop                     Remove containers and volume mounts (MySQL, Redis) "
  echo
  echo "========================= Mac Commands =========================="
  echo "  sync                     Sync local CiviCRM files to containers"
  echo
  echo "========================= Other Commands =========================="
  echo "  env                      Show .env vars (ports, gerrit user)"
  echo "  urls                     Show App URLs"
  echo "  destroy                  Reset your environment. Removes ./src/, .env, config-private, containers and volumes including db and redis."
  echo
  echo "=========================== Custom Builds ========================="
  echo "  You can chain options and commands."
  echo
  echo "  Example: $0 --mac --civicrm --smashpig"
  echo
  echo "  This will enable the Mac-friendly Docker config and then install for CiviCRM and Smashpig"
  echo
}


#set -euo pipefail

if [ $# -eq 0 ]; then
  display_help
  exit 1
fi

# set up .env file
source "$SETUP_DIR/env.sh"
init_env

# run before app setup scripts
init() {
  source "$SETUP_DIR/gerrit.sh"
  source "$SETUP_DIR/project-name.sh"
  source "$SETUP_DIR/bind-mount-dirs.sh"
  source "$SETUP_DIR/xdebug.sh"
  source "$SETUP_DIR/functions.sh"
  source "$SETUP_DIR/config-private.sh"
}

# setup scripts
setup_civicrm_buildkit() {
  source "$SETUP_DIR/civicrm-buildkit.sh"
}

setup_civicrm() {
  time source "$SETUP_DIR/civicrm.sh"
}

setup_civicrm_core() {
  time source "$SETUP_DIR/civicrm-core.sh"
}

setup_payments() {
  source "$SETUP_DIR/proxy.sh"
  time source "$SETUP_DIR/payments.sh"
}

setup_donut() {
  time source "$SETUP_DIR/donut.sh"
}

setup_email_prefs() {
  time source "$SETUP_DIR/email-prefs.sh"
}

setup_civiproxy() {
  time source "$SETUP_DIR/civiproxy.sh"
}

setup_smashpig() {
  source "$SETUP_DIR/proxy.sh"
  time source "$SETUP_DIR/smashpig.sh"
}

setup_tools() {
  time source "$SETUP_DIR/tools.sh"
}

setup_privatebin() {
  time source "$SETUP_DIR/privatebin.sh"
}

show_urls() {
  source "$SETUP_DIR/urls.sh"
}

civicrm_sync() {
  source "$MAC_SCRIPTS_DIR/sync-push-civicrm-config.sh"
  source "$MAC_SCRIPTS_DIR/sync-push-civicrm-buildkit.sh"
  source "$MAC_SCRIPTS_DIR/sync-push-civicrm.sh"
  source "$MAC_SCRIPTS_DIR/sync-push-civicrm-core.sh"
}

drop() {
  source "$SETUP_DIR/drop.sh"
}

# Check for --mac and --skip-reclone flags before executing other build scripts
for arg in "$@"; do
  case $arg in
    --mac)
      USE_MAC_CONFIG="true"
      DOCKER_COMPOSE_FILE=$MAC_DOCKER_COMPOSE_FILE
      ;;
    --skip-reclone)
      SKIP_RECLONE="true"
      ;;
  esac
done

for arg in "$@"; do
  case $arg in
  -h | --help)
    display_help
    exit 0
    ;;
  ## Build flags
  --civicrm)
    init
    announce_install "CiviCRM Buildkit" "CiviCRM WMFF"
    create_xdebug_ini "civicrm"
    setup_civicrm_buildkit
    setup_civicrm
    ;;
  --civicrm-core)
    init
    announce_install "CiviCRM Buildkit" "CiviCRM Core"
    setup_civicrm_buildkit
    setup_civicrm_core
    ;;
  --payments)
    init
    announce_install "Payments Wiki"
    create_xdebug_ini "payments"
    setup_payments
    ;;
  --donut)
    init
    announce_install "Donut/Donate Wiki"
    create_xdebug_ini "donut"
    setup_donut
    ;;
  --civiproxy)
    init
    announce_install "CiviProxy"
    create_xdebug_ini "civiproxy"
    setup_civiproxy
    ;;
  --email-prefs)
    init
    announce_install "Email Preference Center Wiki"
    create_xdebug_ini "email-pref-ctr"
    setup_email_prefs
    ;;
  --smashpig)
    init
    announce_install "SmashPig"
    create_xdebug_ini "smashpig"
    setup_smashpig
    ;;
  --tools)
    init
    announce_install "Fundraising Tools"
    setup_tools
    ;;
  --privatebin)
    init
    announce_install "PrivateBin"
    create_xdebug_ini "privatebin"
    setup_privatebin
    ;;
  --full)
    apps=(
      "Payments Wiki"
      "Donate/Donut Wiki"
      "Email Preference Center Wiki"
      "CiviProxy"
      "SmashPig"
      "CiviCRM Buildkit"
      "CiviCRM"
      "CiviCRM Core"
      "Fundraising Tools"
      "PrivateBin"
    )
    init
    announce_install "${apps[@]}"
    create_xdebug_ini_all
    time (
      setup_payments
      setup_donut
      setup_civiproxy
      setup_email_prefs
      setup_smashpig
      setup_civicrm_buildkit
      setup_civicrm
      setup_civicrm_core
      setup_tools
      setup_privatebin
      echo "Overall Build Time:"
    )
    show_urls
    ;;
  sync)
    civicrm_sync
    ;;
  env)
    show_env
    ;;
  urls)
    show_urls
    ;;
  up)
    docker compose -f $DOCKER_COMPOSE_FILE up -d
    ;;
  down)
    docker compose -f $DOCKER_COMPOSE_FILE down
    ;;
  restart)
    docker compose -f $DOCKER_COMPOSE_FILE restart
    ;;
  status)
    docker compose -f $DOCKER_COMPOSE_FILE ps
    ;;
  drop)
    drop
    ;;
  destroy)
    source "$SETUP_DIR/functions.sh"
    destroy $DOCKER_COMPOSE_FILE
    ;;
  *)
    echo "Unknown flag: $arg"
    ;;
  esac
done
