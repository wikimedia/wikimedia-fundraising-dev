#!/bin/bash

# Script to set up fundraising development environment

# source directories (under src)
PAYMENTS_SRC_DIR="payments"
CIVICRM_BUILDKIT_SRC_DIR="civicrm-buildkit"
CRM_SRC_DIR="civi-sites/wmff"
TOOLS_SRC_DIR="tools"
EMAIL_PREF_CTR_SRC_DIR="email-pref-ctr"

# various settings
FR_MW_CORE_BRANCH="fundraising/REL1_35"
MW_LANG="en"
MW_PASSWORD="dockerpass"
CIVI_ADMIN_PASS=admin
DEFAULT_COMPOSE_PROJECT_NAME=fundraising-dev

# default ports exposed to host
DEFAULT_XDEBUG_PORT=9000
DEFAULT_PAYMENTS_PORT=9001
DEFAULT_EMAIL_PREF_CTR_PORT=9002
DEFAULT_CIVICRM_PORT=32353
DEFAULT_MARIADB_PORT=3306

# Check for existence of a source dir and ask about removing and re-cloning
# $1 is the directory to check, $2 is a friendly name for the repository.
ask_reclone () {
	local reclone=true
	if [ -d $1 ]; then
		read -p "$1 exists. Remove and re-clone $2? [yN] " -r
		if [[ $REPLY =~ ^[Yy]$ ]]; then
			read -p "Are you sure? This will delete $1, including local branches. [yN] " -r
			if ! [[ $REPLY =~ ^[Yy]$ ]]; then
				reclone=false
			fi
		else
			reclone=false
		fi
		echo >&2
	fi
	echo $reclone
}

# Moves file $1 to $1.bkup{n}, where n is the final number of the last backup + 1
backup () {
	i=0
	while [[ -e ${1}.bkup${i} || -L ${1}.bkup${i} ]]; do
		i=$((i+1))
	done
	mv $1 ${1}.bkup${i}
}

# Moves $1 to $2, backing up $2 if it's not identical to $1
backup_mv () {
	if [[ -e $2 || -L $2 ]] && ! cmp -s $1 $2; then
		echo "$2 contains customizations. Backing up."
		backup $2
	fi
	echo "Writing new $2"
	mv $1 $2
}

# If $1 is not a valid port, ask the user for a valid port, with $2 as default
validate_port () {
	input=${1:-$2}
	while ! [[ $input =~ ^[0-9]+$ ]]; do
		read -p "Please enter a valid port [default $2]: " input
		input=${input:-$2}
	done
	echo $input
}

# Check script arguments and set options accordingly
wmf_reg=false
while getopts 'w' flag; do
	case "${flag}" in
		# The -w flag indicates we should run docker-compose with images tagged as
		# being from the WMF registry (which would be as locally built by docker-pkg)
		# rather than from Docker Hub.
		w) wmf_reg=true ;;

		# TODO Add usage help in case of incorrect options
		*) exit 1 ;;
	esac
done

# Store current directory, then change to the directory this script resides in
start_dir=$(pwd)
cd "${0%/*}"
script_dir=$(pwd)
echo $script_dir

set -euo pipefail

# Output all commands except... a few. See
# https://stackoverflow.com/questions/33411737/bash-script-print-commands-but-do-not-print-echo-command/33412142
trap '! [[ "$BASH_COMMAND" =~ ^(echo|read|if|\[ |\[\[ |cat|sleep|printf|cmp|cp|backup|reclone|[A-Za-z_]*=) ]] && \
cmd=`eval echo "$BASH_COMMAND" 2>/dev/null` && ! [[ -z $cmd ]] && echo "$cmd"' DEBUG

echo
echo "****** Setting up fundraising development environment *****"
echo
echo ">>> Please run this script as the same user that will own source code files. <<<"
echo

if [ -d dbdata ]; then
	echo "dbdata, old host directory with database contents, still exists."
	echo "Please remove it or revert to a previous version of fundraising-dev."
	exit 1
fi

if [ -d qdata ]; then
	echo "qdata, old host directory with queue contents, still exists."
	echo "Please remove it or revert to a previous version of fundraising-dev."
	exit 1
fi

# Ask about resetting containers and volumes

read -p "Remove any existing containers for this Docker application? [yN] " -r
if [[ $REPLY =~ ^[Yy]$ ]]; then
	read -p "Reset persistent storage for this Docker application? [yN] " -r
	if [[ $REPLY =~ ^[Yy]$ ]]; then
		docker-compose down -v
	else
		docker-compose down
	fi
else
	docker-compose stop
fi

# GIT_REVIEW_USER environment variable is needed to fetch source code

if [ -z "${GIT_REVIEW_USER:-}" ]; then
	echo "**** Set up git review"
	read -p "Git review user: " GIT_REVIEW_USER
	echo "To skip this step next time, set the GIT_REVIEW_USER environment variable."
	echo
else
	echo "**** Git review user from GIT_REVIEW_USER environment variable: ${GIT_REVIEW_USER}"
	echo
fi

echo "**** Set up source code"

clone_mw=$(ask_reclone "src/${PAYMENTS_SRC_DIR}" "Payments wiki source")

if [ $clone_mw = true ]; then
	echo "**** Cloning and setting up Payments source code in src/${PAYMENTS_SRC_DIR}"

	rm -rf src/${PAYMENTS_SRC_DIR}

	git clone "ssh://${GIT_REVIEW_USER}@gerrit.wikimedia.org:29418/mediawiki/core" \
		--depth=10 --no-single-branch \
		src/${PAYMENTS_SRC_DIR} && \
		scp -p -P 29418 ${GIT_REVIEW_USER}@gerrit.wikimedia.org:hooks/commit-msg \
		"src/${PAYMENTS_SRC_DIR}/.git/hooks/"

	cd src/${PAYMENTS_SRC_DIR}
	git checkout --track remotes/origin/${FR_MW_CORE_BRANCH}
	git submodule update --init --recursive

	# For DonationInterface and FundraisingEmailUnsubscribe, we want to be on the master branch for
	# development purposes. Other extensions should stay at the version indicated by the submodule
	# pointer for the FR_MW_CORE_BRANCH.
	cd extensions/DonationInterface
	git checkout master
	cd ../FundraisingEmailUnsubscribe
	git checkout master

	cd "${script_dir}"
	echo
fi

clone_buildkit=$(ask_reclone "src/${CIVICRM_BUILDKIT_SRC_DIR}" "Civicrm Buildkit source")

if [ $clone_buildkit = true ]; then
	echo "**** Cloning and setting up Civicrm Buildkit source code in src/${CIVICRM_BUILDKIT_SRC_DIR}"

	rm -rf src/${CIVICRM_BUILDKIT_SRC_DIR}

	git clone "ssh://${GIT_REVIEW_USER}@gerrit.wikimedia.org:29418/wikimedia/fundraising/crm/civicrm-buildkit" \
		src/${CIVICRM_BUILDKIT_SRC_DIR} && \
		scp -p -P 29418 ${GIT_REVIEW_USER}@gerrit.wikimedia.org:hooks/commit-msg \
		"src/${CIVICRM_BUILDKIT_SRC_DIR}/.git/hooks/"

	echo
fi

clone_crm=$(ask_reclone "src/${CRM_SRC_DIR}" "WMF crm source repo (includes civicrm and drupal)")

if [ $clone_crm = true ]; then
	echo "**** Cloning and setting up WMF crm source repo in src/${CRM_SRC_DIR}"

	rm -rf src/${CRM_SRC_DIR}
	mkdir -p src/civi-sites

	git clone "ssh://${GIT_REVIEW_USER}@gerrit.wikimedia.org:29418/wikimedia/fundraising/crm" \
		src/${CRM_SRC_DIR} && \
		scp -p -P 29418 ${GIT_REVIEW_USER}@gerrit.wikimedia.org:hooks/commit-msg \
		"src/${CRM_SRC_DIR}/.git/hooks/"

	cd src/${CRM_SRC_DIR}
	git submodule update --init --recursive
	cd "${script_dir}"

	echo
fi

clone_tools=$(ask_reclone "src/${TOOLS_SRC_DIR}" "Tools")

if [ $clone_tools = true ]; then
	echo "**** Cloning and setting up WMF tools repo in src/${TOOLS_SRC_DIR}"

	rm -rf src/${TOOLS_SRC_DIR}
	mkdir -p src/

	git clone "ssh://${GIT_REVIEW_USER}@gerrit.wikimedia.org:29418/wikimedia/fundraising/tools" \
		src/${TOOLS_SRC_DIR} && \
		scp -p -P 29418 ${GIT_REVIEW_USER}@gerrit.wikimedia.org:hooks/commit-msg \
		"src/${TOOLS_SRC_DIR}/.git/hooks/"

	echo
fi

clone_mw=$(ask_reclone "src/${EMAIL_PREF_CTR_SRC_DIR}" "E-mail Preference Center wiki source")

if [ $clone_mw = true ]; then
	echo "**** Cloning and setting up E-mail Preference Center source code in src/${EMAIL_PREF_CTR_SRC_DIR}"

	rm -rf src/${EMAIL_PREF_CTR_SRC_DIR}

	git clone "ssh://${GIT_REVIEW_USER}@gerrit.wikimedia.org:29418/mediawiki/core" \
		--depth=10 --no-single-branch \
		src/${EMAIL_PREF_CTR_SRC_DIR} && \
		scp -p -P 29418 ${GIT_REVIEW_USER}@gerrit.wikimedia.org:hooks/commit-msg \
		"src/${EMAIL_PREF_CTR_SRC_DIR}/.git/hooks/"

	cd src/${EMAIL_PREF_CTR_SRC_DIR}
	git checkout --track remotes/origin/${FR_MW_CORE_BRANCH}
	git submodule update --init --recursive

	# For DonationInterface we want to be on the master branch for
	# development purposes. Other extensions should stay at the version indicated by the submodule
	# pointer for the FR_MW_CORE_BRANCH.
	cd extensions/DonationInterface
	git checkout master

	cd "${script_dir}"
	echo
fi

echo "**** Set up private config repo"

# Migrate old private repo location
if [ -d "config/private" ]; then
	read -p "Old private repo location exists (config/private). Migrate to new location and update? [Yn] " -r
	if ! [[ $REPLY =~ ^[Nn]$ ]]; then
		mv config/private config-private
		cd config-private
		git checkout master
		git pull
		cd "${script_dir}"
	fi
	echo
else
	clone_private=$(ask_reclone "config-private" "private config repo")

	if [ $clone_private = true ]; then
		rm -rf config-private

		echo "See https://phabricator.wikimedia.org/T266093 for remote for private config repo."
		read -p "Please enter remote for private config repo: " private_remote

		while [[ -z $private_remote ]]; do
			read -p "Please enter remote for private config repo (can't be empty): " private_remote
		done
		echo

		echo "**** Cloning private config repo in config-private"
		git clone $private_remote config-private
		echo
	fi
fi

echo "**** Network configuration and project name"

read -p "Port for XDebug [$DEFAULT_XDEBUG_PORT]: " xdebug_port
xdebug_port=$(validate_port $xdebug_port $DEFAULT_XDEBUG_PORT)

read -p "Port for Payments https [$DEFAULT_PAYMENTS_PORT]: " FR_DOCKER_PAYMENTS_PORT
FR_DOCKER_PAYMENTS_PORT=$(validate_port $FR_DOCKER_PAYMENTS_PORT $DEFAULT_PAYMENTS_PORT)

FR_DOCKER_CIVICRM_PORT=$DEFAULT_CIVICRM_PORT
echo "Port for Civicrm is currently not easily configurable. Set to $FR_DOCKER_CIVICRM_PORT."

read -p "Port for E-mail Preference Center https [$DEFAULT_EMAIL_PREF_CTR_PORT]: " \
	FR_DOCKER_EMAIL_PREF_CTR_PORT
FR_DOCKER_EMAIL_PREF_CTR_PORT=$(validate_port $FR_DOCKER_EMAIL_PREF_CTR_PORT $DEFAULT_EMAIL_PREF_CTR_PORT)

read -p "Port for MariaDB connection [$DEFAULT_MARIADB_PORT]: " FR_DOCKER_MARIADB_PORT
FR_DOCKER_MARIADB_PORT=$(validate_port $FR_DOCKER_MARIADB_PORT $DEFAULT_MARIADB_PORT)

echo

echo "You can enter a unique name for this instance of the fundraising-dev setup."
echo "This allows you to set up multiple instances on the same computer and avoid"
echo "collisions between Docker container names."
echo
echo "If you only set up one instance on this computer, you can just use the default."
echo
read -p "Enter a name for this fundraising-dev instance [$DEFAULT_COMPOSE_PROJECT_NAME]: " \
	compose_project_name

if [[ -z $compose_project_name ]]; then
	compose_project_name=$DEFAULT_COMPOSE_PROJECT_NAME
fi


echo
echo "**** Creating .env file"

cat << EOF > /tmp/.env
COMPOSE_PROJECT_NAME=$compose_project_name
FR_DOCKER_PAYMENTS_PORT=${FR_DOCKER_PAYMENTS_PORT}
FR_DOCKER_CIVICRM_PORT=${FR_DOCKER_CIVICRM_PORT}
FR_DOCKER_EMAIL_PREF_CTR_PORT=${FR_DOCKER_EMAIL_PREF_CTR_PORT}
FR_DOCKER_MARIADB_PORT=${FR_DOCKER_MARIADB_PORT}
FR_DOCKER_UID=$(id -u)
FR_DOCKER_GID=$(id -g)
EOF

backup_mv /tmp/.env .env

cat .env
echo

echo "**** Creating XDebug configuration"
cat << EOF > /tmp/payments-xdebug-cli.ini
#### Customize xdebug settings for payments here
#### Note: This file is automatically generated by setup.sh and is ignored by git, so
#### changes will not be tracked. For defaults, see setup.sh.
#### Note: remote_host, remote_log and remote_enable settings are set inside the container
#### from /srv/config/internal/xdebug-common.ini. However, they can be overriden here.

xdebug.remote_port=$xdebug_port
xdebug.remote_autostart=off
EOF

cp /tmp/payments-xdebug-cli.ini /tmp/payments-xdebug-web.ini
cp /tmp/payments-xdebug-cli.ini /tmp/civicrm-xdebug-cli.ini
cp /tmp/payments-xdebug-cli.ini /tmp/civicrm-xdebug-web.ini
cp /tmp/payments-xdebug-cli.ini /tmp/email-pref-ctr-xdebug-cli.ini
cp /tmp/payments-xdebug-cli.ini /tmp/email-pref-ctr-xdebug-web.ini

backup_mv /tmp/payments-xdebug-cli.ini config/payments/xdebug-cli.ini
backup_mv /tmp/payments-xdebug-web.ini config/payments/xdebug-web.ini
backup_mv /tmp/civicrm-xdebug-cli.ini config/civicrm/xdebug-cli.ini
backup_mv /tmp/civicrm-xdebug-web.ini config/civicrm/xdebug-web.ini
backup_mv /tmp/email-pref-ctr-xdebug-cli.ini config/email-pref-ctr/xdebug-cli.ini
backup_mv /tmp/email-pref-ctr-xdebug-web.ini config/email-pref-ctr/xdebug-web.ini

echo

echo "**** Start application"
if [ $wmf_reg = true ]; then
	docker-compose -f docker-compose.yml -f docker-compose-wmf-reg.yml up -d
else
	docker-compose up -d
fi
echo

# Wait for db service

echo "**** Waiting for database to be ready"
while ! docker-compose exec payments \
	mysqladmin ping -h database -u root --silent > /dev/null; do
	sleep 0.5 && printf '.'
done
echo "Database ready"
echo

echo "**** Composer"

read -p "Payments: run composer install? [Yn] " -r
if [[ $REPLY =~ ^[Yy]$ ]] || [ -z $REPLY ]; then
	# TODO put this in a separate script
	docker-compose exec -w "/var/www/html/" payments composer install
fi
echo

read -p "Civicrm buildkit: run composer install? [Yn] " -r
if [[ $REPLY =~ ^[Yy]$ ]] || [ -z $REPLY ]; then
	# TODO put this in a separate script
	docker-compose exec -w "/srv/civicrm-buildkit" civicrm composer install
fi
echo

read -p "Civicrm buildkit: run npm install? [Yn] " -r
if [[ $REPLY =~ ^[Yy]$ ]] || [ -z $REPLY ]; then
	# TODO put this in a separate script
	docker-compose exec -w "/srv/civicrm-buildkit" civicrm npm install
fi
echo

read -p "Email Preference Center: run composer install? [Yn] " -r
if [[ $REPLY =~ ^[Yy]$ ]] || [ -z $REPLY ]; then
	# TODO put this in a separate script
	docker-compose exec -w "/var/www/html/" email-pref-ctr composer install
fi
echo

# if Payments LocalSettings exists, ask about replacing or skipping install step

echo "**** Payments: install.php, LocalSettings.php and update.php"

payments_install=true
localsettings_fn=src/${PAYMENTS_SRC_DIR}/LocalSettings.php

# Prepare customized LocalSettings.php
	cat << EOF > /tmp/LocalSettings.php
<?php
require( '/srv/config/exposed/payments/LocalSettings.php');
EOF

if [[ -e $localsettings_fn || -L $localsettings_fn ]]; then
	read -p \
		"Run install.php and set up LocalSettings.php? [yN] " \
		-r
	echo
	if [[ $REPLY =~ ^[Yy]$ ]]; then
		# Back up LocalSettings.php if it's not the standard version
		if ! cmp -s $localsettings_fn /tmp/LocalSettings.php; then
			echo "LocalSettings.php contains customizations. Backing it up."
			backup $localsettings_fn
		else
			rm $localsettings_fn
		fi
	else
		payments_install=false
	fi
fi

if [ $payments_install = true ]; then
	echo "**** Running maintenance/install.php"
	docker-compose exec -w "/var/www/html/" payments php maintenance/install.php \
		--server https://localhost:${FR_DOCKER_PAYMENTS_PORT} \
		--dbname=payments \
		--dbuser=root \
		--dbserver=database \
		--lang=${MW_LANG} \
		--scriptpath="" \
		--pass=${MW_PASSWORD} Payments admin

	echo "Writing $localsettings_fn"
	mv /tmp/LocalSettings.php $localsettings_fn
	echo
fi

echo "**** maintenance/update.php"

payments_update=true

# Only ask about running update.php if we didn't run install.php; otherwise we have to run it.
if [ $payments_install = false ]; then
	read -p "Run update.php? [yN] " -r
	echo
	if ! [[ $REPLY =~ ^[Yy]$ ]]; then
		payments_update=false
	fi
fi

if [ $payments_update = true ]; then
	docker-compose exec -w "/var/www/html/" payments php maintenance/update.php --quick
fi
echo

echo "**** Update Payments wiki text"

./payments-update-text.sh
echo

echo "**** Set up Civicrm"

read -p "Set up config and run civibuild create to create wmff & dmaster sites? [Yn] " -r
echo

if [[ $REPLY =~ ^[Yy]$ ]] || [ -z $REPLY ]; then

	echo "Clean up any untracked files that may remain from previous builds."
	rm -f src/civi-sites/wmff.sh
	rm -f src/civi-sites/wmff/sites/default/civicrm.settings.php
	rm -f src/civi-sites/dmaster.sh
	rm -f src/civi-sites/dmaster/web/sites/default/civicrm.settings.php
	rm -rf srv/civi-sites/dmaster/web/sites/default/files/civicrm/templates_c/*
	rm -rf srv/civi-sites/wmff/sites/default/files/civicrm/templates_c/*
	rm -rf config/civicrm/amp/my.cnf.d/
	rm -rf config/civicrm/amp/nginx.d/
	rm -rf config/civicrm/amp/log/
	rm -rf config/civicrm/amp/apache.d/*.conf

	echo "Link config/civicrm/civibuild.conf to required location under buildkit source."
	docker-compose exec civicrm ln -fs /srv/config/exposed/civicrm/civibuild.conf /srv/civicrm-buildkit/app/civibuild.conf
	echo

	docker-compose exec -w "/srv/civi-sites/" civicrm civibuild create \
		wmff --admin-pass $CIVI_ADMIN_PASS

  docker-compose exec -w "/srv/civi-sites/" civicrm civibuild create \
		dmaster --admin-pass $CIVI_ADMIN_PASS
	echo
fi

# if E-mail Preference Center LocalSettings exists, ask about replacing or skipping install step

echo "**** E-mail Preference Center: install.php, LocalSettings.php and update.php"

email_pref_ctr_install=true
localsettings_fn=src/${EMAIL_PREF_CTR_SRC_DIR}/LocalSettings.php

# Prepare customized LocalSettings.php
	cat << EOF > /tmp/LocalSettings.php
<?php
require( '/srv/config/exposed/email-pref-ctr/LocalSettings.php');
EOF

if [[ -e $localsettings_fn || -L $localsettings_fn ]]; then
	read -p \
		"Run install.php and set up LocalSettings.php? [yN] " \
		-r
	echo
	if [[ $REPLY =~ ^[Yy]$ ]]; then
		# Back up LocalSettings.php if it's not the standard version
		if ! cmp -s $localsettings_fn /tmp/LocalSettings.php; then
			echo "LocalSettings.php contains customizations. Backing it up."
			backup $localsettings_fn
		else
			rm $localsettings_fn
		fi
	else
		email_pref_ctr_install=false
	fi
fi

if [ $email_pref_ctr_install = true ]; then
	echo "**** Running maintenance/install.php"
	docker-compose exec -w "/var/www/html/" email-pref-ctr php maintenance/install.php \
		--server https://localhost:${FR_DOCKER_EMAIL_PREF_CTR_PORT} \
		--dbname=email-pref-ctr \
		--dbuser=root \
		--dbserver=database \
		--lang=${MW_LANG} \
		--scriptpath="" \
		--pass=${MW_PASSWORD} "E-mail Preference Center" admin

	echo "Writing $localsettings_fn"
	mv /tmp/LocalSettings.php $localsettings_fn
	echo
fi

echo "**** maintenance/update.php"

email_pref_ctr_update=true

# Only ask about running update.php if we didn't run install.php; otherwise we have to run it.
if [ $email_pref_ctr_install = false ]; then
	read -p "Run update.php? [yN] " -r
	echo
	if ! [[ $REPLY =~ ^[Yy]$ ]]; then
		email_pref_ctr_update=false
	fi
fi

if [ $email_pref_ctr_update = true ]; then
	docker-compose exec -w "/var/www/html/" email-pref-ctr php maintenance/update.php --quick
fi
echo


# go back to whatever directory we were in to start
cd "${start_dir}"

echo "Payments URL: https://localhost:$FR_DOCKER_PAYMENTS_PORT"
echo "WMF CiviCRM install URL: https://wmff.localhost:$FR_DOCKER_CIVICRM_PORT/civicrm"
echo "Generic CiviCRM install (based on upstream master) URL: https://dmaster.localhost:$FR_DOCKER_CIVICRM_PORT/civicrm"
echo "Civicrm user/password: admin/$CIVI_ADMIN_PASS"
echo "E-mail Preference Center URL: https://localhost:$FR_DOCKER_EMAIL_PREF_CTR_PORT/index.php/Special:EmailPreferences"
echo
