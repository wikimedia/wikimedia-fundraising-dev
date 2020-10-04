#!/bin/bash

# Script to set up fundraising development environment

set -euo pipefail

FR_CORE_BRANCH="fundraising/REL1_35"
MW_SRC_DIR="mediawiki-payments"
MW_LANG="en"
MW_PASSWORD="dockerpass"

# Output all commands except... a few. See
# https://stackoverflow.com/questions/33411737/bash-script-print-commands-but-do-not-print-echo-command/33412142
trap '! [[ "$BASH_COMMAND" =~ ^(echo|read|if|\[ |\[\[ |cat|sleep|printf|[A-Za-z_]*=) ]] && \
cmd=`eval echo "$BASH_COMMAND" 2>/dev/null` && ! [[ -z $cmd ]] && echo "$cmd"' DEBUG

echo
echo "****** Setting up fundraising development environment *****"
echo

# Check for existing containers for this application

if ! [[ -z $(docker-compose ps -q) ]]; then
	read -p "Existing containers found for this Docker application. Remove them? [yN] " -n 1 -r
	echo
	if [[ $REPLY =~ ^[Yy]$ ]]; then
		docker-compose down
	else
		docker-compose stop
	fi
	echo
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

CLONE_MW=true
if [ -d "src/${MW_SRC_DIR}" ]; then
	read -p "src/${MW_SRC_DIR} exists. Remove and re-clone payments wiki source? [yN] " -n 1 -r
	echo
	if [[ $REPLY =~ ^[Yy]$ ]]; then
		rm -rf src/${MW_SRC_DIR}
	else
		CLONE_MW=false
	fi
	echo
fi

if [ $CLONE_MW = true ]; then
	echo "**** Cloning and setting up Mediawiki source code in src/${MW_SRC_DIR}"
	git clone "ssh://${GIT_REVIEW_USER}@gerrit.wikimedia.org:29418/mediawiki/core" \
		--depth=10 --no-single-branch \
		src/${MW_SRC_DIR} && \
		scp -p -P 29418 ${GIT_REVIEW_USER}@gerrit.wikimedia.org:hooks/commit-msg \
		"src/${MW_SRC_DIR}/.git/hooks/"

	cd src/${MW_SRC_DIR}

	git checkout --track remotes/origin/${FR_CORE_BRANCH}

	git submodule update --init --recursive
	cd ../../
	echo
fi

echo "**** Configure ports"

read -p "Port for Mediawiki https [9001]: " MW_DOCKER_PORT
MW_DOCKER_PORT="${MW_DOCKER_PORT:-9001}"
echo

echo "**** Creating .env file"

cat << EOF > .env
MW_DOCKER_PORT=${MW_DOCKER_PORT}
MW_SRC_DIR=${MW_SRC_DIR}
MW_DOCKER_UID=$(id -u)
MW_DOCKER_GID=$(id -g)
EOF

cat .env
echo

echo "**** Check for existing mariadb databases"

if ! [[ -z $(find dbdata/ ! \( -name 'dbdata' -o -name '.gitignore' \)) ]]; then
	read -p "Existing mariadb contents found. Erase all databases? [yN] " -n 1 -r
	echo
	if [[ $REPLY =~ ^[Yy]$ ]]; then
		find dbdata/ ! \( -name 'dbdata' -o -name '.gitignore' \) -exec rm -rf {} +
	fi
else
	echo "No database contents found"
fi
echo

echo "**** Start application"
docker-compose up -d
echo

# Wait for db service

echo "**** Waiting for database to be ready"
while ! docker-compose exec mediawiki-payments \
	mysqladmin ping -h database -u root --silent > /dev/null; do
	sleep 0.5 && printf '.'
done
echo "Database ready"
echo

echo "**** Composer"

read -p "Run composer install? [Yn] " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]] || [ -z $REPLY ]; then
	# TODO put this in a separate script
	docker-compose exec -w "/var/www/html/" mediawiki-payments composer install
fi
echo

# if LocalSettings exists, ask about replacing or skipping install step

echo "**** Payments: install.php, LocalSettings.php and update.php"
echo

MW_INSTALL=true
LOCALSETTINGS_FN=src/${MW_SRC_DIR}/LocalSettings.php

if [[ -e $LOCALSETTINGS_FN || -L $LOCALSETTINGS_FN ]]; then
	read -p \
		"${LOCALSETTINGS_FN} exists. Back it up, run install.php and customize LocalSettings.php? [yN] " \
		-n 1 -r
	echo
	if [[ $REPLY =~ ^[Yy]$ ]]; then
		# Make a backup of LocalSettings.php, using a number after the extension in case
		# there are already previous backups.
		i=0
		while [[ -e ${LOCALSETTINGS_FN}.bkup${i} || -L ${LOCALSETTINGS_FN}.bkup${i} ]]; do
			i=$((i+1))
		done
		mv $LOCALSETTINGS_FN ${LOCALSETTINGS_FN}.bkup${i}
	else
		MW_INSTALL=false
	fi
fi

if [ $MW_INSTALL = true ]; then
	echo "**** Running maintenance/install.php"
	docker-compose exec -w "/var/www/html/" mediawiki-payments php maintenance/install.php \
		--server https://localhost:${MW_DOCKER_PORT} \
		--dbname=payments \
		--dbuser=root \
		--dbserver=database \
		--lang=${MW_LANG} \
		--scriptpath="" \
		--pass=${MW_PASSWORD} Payments admin

	echo
	echo "**** Customizing LocalSettings.php"
	echo

	# Substitute $wgServer line in newly created LocalSettings.php to get port from environment
	sed -i '/wgServer/c\\$wgServer = "https://localhost:" . getenv( "MW_DOCKER_PORT" );' \
		src/${MW_SRC_DIR}/LocalSettings.php

	# Add custom settings from LocalSettings.custom.php
	cat LocalSettings.custom.php >> src/${MW_SRC_DIR}/LocalSettings.php
fi

echo "**** maintenance/update.php"

MW_UPDATE=true

# Only ask about running update.php if we didn't run install.php; otherwise we have to run it.
if [ $MW_INSTALL = false ]; then
	read -p "run update.php? [yN] " -n 1 -r
	echo
	echo
	if ! [[ $REPLY =~ ^[Yy]$ ]]; then
		MW_UPDATE=false
	fi
fi

if [ $MW_UPDATE = true ]; then
	docker-compose exec -w "/var/www/html/" mediawiki-payments php maintenance/update.php --quick
fi