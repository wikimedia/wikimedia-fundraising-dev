#!/bin/bash

SETUP_DIR="./build"
SCRIPTS_DIR="./scripts"
DOCKER_COMPOSE_FILE="docker-compose.yml"
MAC_SCRIPTS_DIR="./scripts/mac"
MAC_DOCKER_COMPOSE_FILE="docker-compose-mac.yml"
USE_MAC_CONFIG="false"
SKIP_RECLONE="false"
CONFIG_PRIVATE_CALLED_DIRECTLY="false"

display_help() {
  echo "Usage: $0 [OPTION]... [COMMAND]"
  echo "Fundraising-dev setup script."
  echo
  echo "  -h, --help               Display this help and exit"
  echo
  echo "========================= Setup Options ========================="
  echo "  --skip-reclone                Do not ask to reclone any repos"
  echo "  --full                        Set up everything!"
  echo "  --civicrm                     Set up CiviCRM WMF (our version, on standalone)"
  echo "  --civicrm-core                Set up CiviCRM Core (for upstream testing)"
  echo "  --civicrm-standalone          Set up CiviCRM Standalone"
  echo "  --civicrm-standalone-composer Set up CiviCRM Standalone with Composer"
  echo "  --core                        Set up vanilla Core MediaWiki"
  echo "  --payments                    Set up PaymentsWiki"
  echo "  --donut                       Set up Donate/Donut Wiki"
  echo "  --email-prefs                 Set up Email-Pref/Donor Portal Wiki"
  echo "  --fraud-scoring               Set up Fraud scoring service"
  echo "  --civiproxy                   Set up CiviProxy (Email-Preference Centre Wiki)"
  echo "  --smashpig                    Set up Smashpig Listeners (IPN testing)"
  echo "  --tools                       Set up Fundraising-tools (incl. Silverpop Export scripts)"
  echo "  --django                      Set up DjangoBannerStats"
  echo "  --privatebin                  Set up PrivateBin"
  echo "  --config-private              Set up config-private repo"
  echo
  echo "========================= Docker Commands ========================="
  echo "  up                       Create and start up Docker containers"
  echo "  down                     Stop and remove Docker containers"
  echo "  start                    Start up any stopped Docker containers"
  echo "  stop                     Stop any running Docker containers"
  echo "  restart                  Restart all Docker containers"
  echo "  status                   Show status of installed apps and bound ports"
  echo "  drop                     Remove containers AND volume mounts (MySQL, Redis, Mac-specific mounts) "
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
  echo "  You can pass multiple options to install only what you need"
  echo
  echo "  Example: $0 --civicrm --smashpig --tools"
  echo
  echo "  This will install CiviCRM, Smashpig and Fundraising-tools"
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

# mac optimisations
if [ "$DOCKER_HOST_OS" = "Darwin" ]; then
  echo "**** MacOS Detected: using optimised docker-compose-mac.yml config "
  echo
  USE_MAC_CONFIG="true"
  DOCKER_COMPOSE_FILE=$MAC_DOCKER_COMPOSE_FILE
fi

DOCKER_COMPOSE_COMMAND_BASE="docker compose -f $DOCKER_COMPOSE_FILE"
if [ -f docker-compose.override.yml ]; then
  DOCKER_COMPOSE_COMMAND_BASE="$DOCKER_COMPOSE_COMMAND_BASE -f docker-compose.override.yml"
fi

# run before app setup scripts
init() {
  source "$SETUP_DIR/gerrit.sh"
  source "$SETUP_DIR/project-name.sh"
  source "$SETUP_DIR/bind-mount-dirs.sh"
  source "$SETUP_DIR/xdebug.sh"
  source "$SETUP_DIR/debug.sh"
  source "$SETUP_DIR/functions.sh"
  source "$SETUP_DIR/config-private.sh"
}

# setup scripts
setup_civicrm_buildkit() {
  source "$SETUP_DIR/civicrm-buildkit.sh"
}

setup_civicrm() {
  time source "$SETUP_DIR/civicrm-wmf.sh"
}

setup_civicrm_core() {
  time source "$SETUP_DIR/civicrm-core.sh"
}

setup_civicrm_standalone() {
  time source "$SETUP_DIR/civicrm-standalone.sh"
}

setup_civicrm_standalone_composer() {
  time source "$SETUP_DIR/civicrm-standalone-composer.sh"
}

setup_core() {
  time source "$SETUP_DIR/core.sh"
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

setup_fraud_scoring() {
  time source "$SETUP_DIR/fraud-scoring.sh"
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

setup_djangobannerstats() {
  time source "$SETUP_DIR/django-banner-stats.sh"
}

setup_gr4vy() {
  time source "$SETUP_DIR/gr4vy.sh"
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
  source "$MAC_SCRIPTS_DIR/sync-push-civicrm-wmf.sh"
  source "$MAC_SCRIPTS_DIR/sync-push-civicrm-core.sh"
  source "$MAC_SCRIPTS_DIR/sync-push-civicrm-standalone.sh"
}

drop() {
  source "$SETUP_DIR/drop.sh"
}

setup_config_private() {
    CONFIG_PRIVATE_CALLED_DIRECTLY="true"
    source "$SETUP_DIR/functions.sh"
    source "$SETUP_DIR/config-private.sh"
    # needed to remount the config-private dir
    docker_compose_restart "$DOCKER_COMPOSE_FILE"
}

# Check for --skip-reclone flags before executing other build scripts
for arg in "$@"; do
  case $arg in
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
    # ignore --skip-reclone due to being handled in the first block
  --skip-reclone)
    ;;
  branch=*)
    MW_CORE_BRANCH="${arg#branch=}"
    ;;
  ## Build flags
  --civicrm)
    init
    announce_install "CiviCRM Buildkit" "CiviCRM WMF"
    create_xdebug_ini "civicrm"
    create_debug_ini "civicrm"
    setup_civicrm_buildkit
    setup_civicrm
    ;;
  --civicrm-core)
    init
    announce_install "CiviCRM Buildkit" "CiviCRM Core"
    setup_civicrm_buildkit
    setup_civicrm_core
    ;;
  --civicrm-standalone)
    init
    announce_install "CiviCRM Buildkit" "CiviCRM Standalone"
    setup_civicrm_buildkit
    setup_civicrm_standalone
    ;;
  --civicrm-standalone-composer)
    init
    announce_install "CiviCRM Buildkit" "CiviCRM Standalone on Composer"
    setup_civicrm_buildkit
    setup_civicrm_standalone_composer
    ;;
  --core)
    init
    announce_install "Core Wiki"
    create_xdebug_ini "core"
    create_debug_ini "core"
    setup_core
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
  --fraud-scoring)
    init
    announce_install "Fraud scoring service"
    setup_fraud_scoring
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
  --django)
    init
    announce_install "DjangoBannerStats"
    setup_djangobannerstats
    ;;
  --gr4vy)
    init
    announce_install "Gr4vy POC"
    setup_gr4vy
    ;;
  --privatebin)
    init
    announce_install "PrivateBin"
    create_xdebug_ini "privatebin"
    setup_privatebin
    ;;
  --config-private)
    setup_config_private
    ;;
  --full)
    apps=(
      "Core Wiki"
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
      "Fraud scoring service"
    )
    init
    announce_install "${apps[@]}"
    create_xdebug_ini_all
    create_debug_ini_all
    time (
      setup_core
      setup_payments
      setup_donut
      setup_civiproxy
      setup_email_prefs
      setup_fraud_scoring
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
    $DOCKER_COMPOSE_COMMAND_BASE up -d
    ;;
  down)
    $DOCKER_COMPOSE_COMMAND_BASE down
    ;;
  start)
    $DOCKER_COMPOSE_COMMAND_BASE start
    ;;
  stop)
    $DOCKER_COMPOSE_COMMAND_BASE stop
    ;;
  restart)
    $DOCKER_COMPOSE_COMMAND_BASE restart
    ;;
  status)
    $DOCKER_COMPOSE_COMMAND_BASE ps
    ;;
  drop)
    drop
    ;;
  destroy)
    source "$SETUP_DIR/functions.sh"
    destroy
    ;;
  *)
    echo "Unknown flag: $arg"
    ;;
  esac
done
