#!/bin/bash

# Script to set up fundraising development environment

# source directories (under src)
PAYMENTS_SRC_DIR="payments"
DONUT_SRC_DIR="donut"
CIVICRM_BUILDKIT_SRC_DIR="civicrm-buildkit"
CRM_SRC_DIR="civi-sites/wmff"
CRM_DMASTER_SRC_DIR="civi-sites/dmaster"
CIVIPROXY_SRC_DIR="civiproxy"
TOOLS_SRC_DIR="tools"
EMAIL_PREF_CTR_SRC_DIR="email-pref-ctr"
SMASHPIG_SRC_DIR="smashpig"
PRIVATEBIN_SRC_DIR="privatebin"

# various settings
FR_MW_CORE_BRANCH="fundraising/REL1_39"
MW_LANG="en"
MW_PASSWORD="dockerpass"
CIVI_ADMIN_PASS="admin"
SMASHPIG_DB_USER_PASSWORD="dockerpass"
DEFAULT_COMPOSE_PROJECT_NAME="fundraising-dev"
DEFAULT_PROXY_FORWARD_ID=1

# default ports exposed to host
DEFAULT_XDEBUG_PORT=9000
DEFAULT_PAYMENTS_PORT=9001
DEFAULT_PAYMENTS_HTTP_PORT=9009
DEFAULT_DONUT_PORT=9010
DEFAULT_DONUT_HTTP_PORT=9011
DEFAULT_EMAIL_PREF_CTR_PORT=9002
DEFAULT_CIVICRM_PORT=32353
DEFAULT_CIVIPROXY_PORT=9005
DEFAULT_SMASHPIG_PORT=9006
DEFAULT_PRIVATEBIN_RO_PORT=9007
DEFAULT_PRIVATEBIN_RW_PORT=9008
DEFAULT_MARIADB_PORT=3306
DEFAULT_SMTP_PORT=1025
DEFAULT_MAILCATCHER_PORT=1080
# Newer versions of SCP will default to using SFTP, which fails with gerrit.
EXTRA_SCP_OPTION=$([[ `ssh -V 2>&1 | grep -E -o OpenSSH_[0-9]+ | sed -e 's/OpenSSH_//'` -gt 8 ]] && echo '-O')

skip_install_dependencies=false
skip_reclone=false

# getopt seems terrible, let's just loop over the args
for arg in "$@"
do
	case "$arg" in
	--skip-deps)	skip_install_dependencies=true
			;;
	--skip-reclone)	skip_reclone=true
			;;
	*)		echo "Unknown argument $arg"
			;;
	esac
done

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

# Copies file $1 to $1.bkup{n}, where n is the final number of the last backup + 1
backup () {
	i=0
	while [[ -e ${1}.bkup${i} || -L ${1}.bkup${i} ]]; do
		i=$((i+1))
	done
	cp $1 ${1}.bkup${i}
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

# TODO: transitional code, simplify once all containers are updated to bullseye
# and xdebug 2 no longer needs to be supported.
# xdebug 2 (buster) uses remote_port while xdebug 3 (bullseye) uses client_port
# Check for $2 xdebug ini file, and writes default if it doesn't exist.
# (Default file is assumed to exist at /tmp/default-xdebug$1.ini, where $1 is 2 or 3,
# specifying the version of xdebug to be used.)
# Check if any existing file is for the right version of xdebug and create a fresh one
# if not. Otherwise see if the port set in the xdebug file is the one requested. If not,
# update it. (Also assumes $xdebug_port has been set already.)
create_or_maybe_update_xdebug_ini () {
	if [[ ! -e $2 ]]; then
		echo "Creating $2."
		cp /tmp/default-xdebug$1.ini $2
		echo

	else
		port_from_file=$(sed -n 's/.*xdebug.\(remote\|client\)_port *= *\([^ ]*.*\)/\2/p' < $2)
		file_version=$(grep -q remote_port $2 && echo 2 || echo 3)
		if [[ $file_version != $1 ]]; then
		  echo "$2 exists but is for the wrong xdebug version. Backing up and creating a new file."
		  echo "Please review any customized settings that may need to be copied across."
		  backup $2
		  cp /tmp/default-xdebug$1.ini $2
		elif [[ $port_from_file != $xdebug_port ]]; then
			echo "Existing $2 sets a different port for xdebug; updating and backing up."
			backup $2
			sed -i -e "s/.*xdebug.remote_port=.*/xdebug.remote_port=$xdebug_port/" $2
			sed -i -e "s/.*xdebug.client_port=.*/xdebug.client_port=$xdebug_port/" $2
		else
			echo "$2 exists and does not need updating."
		fi
	fi
}

# Store current directory, then change to the directory this script resides in
start_dir=$(pwd)
cd "${0%/*}"
script_dir=$(pwd)
echo $script_dir

set -euo pipefail

# Output all commands except... a few. See
# https://stackoverflow.com/questions/33411737/bash-script-print-commands-but-do-not-print-echo-command/33412142
trap '! [[ "$BASH_COMMAND" =~ ^(echo|read|if|\[ |\[\[ |cat|sleep|printf|cmp|cp|source|backup|reclone|for|create_or_maybe|[A-Za-z_]*=) ]] && \
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
echo

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

if [ $skip_reclone = false ]; then
	echo "**** Set up source code"

	clone_mw=$(ask_reclone "src/${PAYMENTS_SRC_DIR}" "Payments wiki source")

	if [ $clone_mw = true ]; then
		echo "**** Cloning and setting up Payments source code in src/${PAYMENTS_SRC_DIR}"

		rm -rf src/${PAYMENTS_SRC_DIR}

		git clone "ssh://${GIT_REVIEW_USER}@gerrit.wikimedia.org:29418/mediawiki/core" \
			--depth=10 --no-single-branch \
			src/${PAYMENTS_SRC_DIR} && \
			scp $EXTRA_SCP_OPTION -p -P 29418 ${GIT_REVIEW_USER}@gerrit.wikimedia.org:hooks/commit-msg \
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

	clone_donut=$(ask_reclone "src/${DONUT_SRC_DIR}" "Donut wiki source")

	if [ $clone_donut = true ]; then
		echo "**** Cloning and setting up Donutwiki source code in src/${DONUT_SRC_DIR}"

		rm -rf src/${DONUT_SRC_DIR}

		git clone "ssh://${GIT_REVIEW_USER}@gerrit.wikimedia.org:29418/mediawiki/core" \
			--depth=10 --no-single-branch \
			src/${DONUT_SRC_DIR} && \
			scp $EXTRA_SCP_OPTION -p -P 29418 ${GIT_REVIEW_USER}@gerrit.wikimedia.org:hooks/commit-msg \
			"src/${DONUT_SRC_DIR}/.git/hooks/"

		cat << EOF >> src/${DONUT_SRC_DIR}/composer.local.json
{
	"config": {
		"platform": {
			"php": "7.4.30"
		}
	},
	"extra": {
		"merge-plugin": {
			"include": [
				"extensions/*/composer.json",
				"skins/*/composer.json"
			]
		}
	}
}
EOF

		# For FundraiserLandingPage and LandingCheck, we want to be on the master branch for
		# development purposes.
		# TODO: Other extensions should stay at the version indicated by the submodule
		# pointer for latest mediawiki core tag deployed to donatewiki.
		# Oh hey, donut even depends on DonationInterface for some i18n strings!
		cd src/${DONUT_SRC_DIR}/extensions
		for i in CentralNotice CodeEditor CodeMirror DonationInterface EventLogging FundraiserLandingPage FundraisingTranslateWorkflow LandingCheck Linter ParserFunctions Scribunto TemplateSandbox TemplateStyles Translate UniversalLanguageSelector WikiEditor
		do
			git clone "ssh://${GIT_REVIEW_USER}@gerrit.wikimedia.org:29418/mediawiki/extensions/$i" \
				--depth=10 --no-single-branch && \
			scp $EXTRA_SCP_OPTION -p -P 29418 ${GIT_REVIEW_USER}@gerrit.wikimedia.org:hooks/commit-msg \
			"$i/.git/hooks/"
		done
		cd ../skins
		git clone "ssh://${GIT_REVIEW_USER}@gerrit.wikimedia.org:29418/mediawiki/skins/Vector" \
			--depth=10 --no-single-branch && \
		scp $EXTRA_SCP_OPTION -p -P 29418 ${GIT_REVIEW_USER}@gerrit.wikimedia.org:hooks/commit-msg \
			"Vector/.git/hooks/"

		cd "${script_dir}"
		echo
	fi

	clone_buildkit=$(ask_reclone "src/${CIVICRM_BUILDKIT_SRC_DIR}" "Civicrm Buildkit source")

	if [ $clone_buildkit = true ]; then
		echo "**** Cloning and setting up Civicrm Buildkit source code in src/${CIVICRM_BUILDKIT_SRC_DIR}"

		rm -rf src/${CIVICRM_BUILDKIT_SRC_DIR}

		git clone "https://github.com/civicrm/civicrm-buildkit.git" src/${CIVICRM_BUILDKIT_SRC_DIR}

		echo
	fi

	clone_crm=$(ask_reclone "src/${CRM_SRC_DIR}" "WMF crm source repo (includes civicrm and drupal)")

	if [ $clone_crm = true ]; then
		echo "**** Cloning and setting up WMF crm source repo in src/${CRM_SRC_DIR}"

		rm -rf src/${CRM_SRC_DIR}
		mkdir -p src/civi-sites

		git clone "ssh://${GIT_REVIEW_USER}@gerrit.wikimedia.org:29418/wikimedia/fundraising/crm" \
			src/${CRM_SRC_DIR} && \
			scp $EXTRA_SCP_OPTION -p -P 29418 ${GIT_REVIEW_USER}@gerrit.wikimedia.org:hooks/commit-msg \
			"src/${CRM_SRC_DIR}/.git/hooks/"

		cd src/${CRM_SRC_DIR}
		git submodule update --init --recursive
		cd "${script_dir}"

		echo
	fi

	clone_crm_dmaster=$(ask_reclone "src/${CRM_DMASTER_SRC_DIR}" "CiviCRM dmaster repo (will be recloned in Civi setup)")

	if [ $clone_crm_dmaster = true ]; then
		echo "**** CiviCRM dmaster repo empty (or removed). To clone (or reclone), answer 'y' below when asked to run civibuild.)"

		rm -rf src/${CRM_DMASTER_SRC_DIR}
		mkdir -p src/civi-sites
		cd "${script_dir}"

		echo
	fi

	clone_civiproxy=$(ask_reclone "src/${CIVIPROXY_SRC_DIR}" "Civiproxy source")

	if [ $clone_civiproxy = true ]; then
		echo "**** Cloning and setting up Civiproxy in src/${CIVIPROXY_SRC_DIR}"

		rm -rf src/${CIVIPROXY_SRC_DIR}

		git clone "ssh://${GIT_REVIEW_USER}@gerrit.wikimedia.org:29418/wikimedia/fundraising/crm/civiproxy" \
			src/${CIVIPROXY_SRC_DIR} && \
			scp $EXTRA_SCP_OPTION -p -P 29418 ${GIT_REVIEW_USER}@gerrit.wikimedia.org:hooks/commit-msg \
			"src/${CIVIPROXY_SRC_DIR}/.git/hooks/"

		echo
	fi

	clone_tools=$(ask_reclone "src/${TOOLS_SRC_DIR}" "Tools")

	if [ $clone_tools = true ]; then
		echo "**** Cloning and setting up WMF tools repo in src/${TOOLS_SRC_DIR}"

		rm -rf src/${TOOLS_SRC_DIR}
		mkdir -p src/

		git clone "ssh://${GIT_REVIEW_USER}@gerrit.wikimedia.org:29418/wikimedia/fundraising/tools" \
			src/${TOOLS_SRC_DIR} && \
			scp $EXTRA_SCP_OPTION -p -P 29418 ${GIT_REVIEW_USER}@gerrit.wikimedia.org:hooks/commit-msg \
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
			scp $EXTRA_SCP_OPTION -p -P 29418 ${GIT_REVIEW_USER}@gerrit.wikimedia.org:hooks/commit-msg \
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

	clone_smashpig=$(ask_reclone "src/${SMASHPIG_SRC_DIR}" "SmashPig")

	if [ $clone_smashpig = true ]; then
		echo "**** Cloning and setting up SmashPig in src/${SMASHPIG_SRC_DIR}"

		rm -rf src/${SMASHPIG_SRC_DIR}
		mkdir -p src/

		git clone "ssh://${GIT_REVIEW_USER}@gerrit.wikimedia.org:29418/wikimedia/fundraising/SmashPig" \
			src/${SMASHPIG_SRC_DIR} && \
			scp $EXTRA_SCP_OPTION -p -P 29418 ${GIT_REVIEW_USER}@gerrit.wikimedia.org:hooks/commit-msg \
			"src/${SMASHPIG_SRC_DIR}/.git/hooks/"

		echo
	fi

	clone_privatebin=$(ask_reclone "src/${PRIVATEBIN_SRC_DIR}" "PrivateBin source")

	if [ $clone_privatebin = true ]; then
		echo "**** Cloning and setting up PrivateBin source code in src/${PRIVATEBIN_SRC_DIR}"

		rm -rf src/${PRIVATEBIN_SRC_DIR}

		git clone "ssh://${GIT_REVIEW_USER}@gerrit.wikimedia.org:29418/wikimedia/fundraising/privatebin" \
			src/${PRIVATEBIN_SRC_DIR} && \
			scp $EXTRA_SCP_OPTION -p -P 29418 ${GIT_REVIEW_USER}@gerrit.wikimedia.org:hooks/commit-msg \
			"src/${PRIVATEBIN_SRC_DIR}/.git/hooks/"

		echo
	fi

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

echo "**** Configuration: ports and project name"

# If there's an.env file, read it in as source, modifying variable names to the names used
# as defaults for ports and project name

if [[ -e .env ]]; then
	echo ".env exists; setting default values from there."
	source <(sed 's/COMPOSE_PROJECT_NAME/DEFAULT_COMPOSE_PROJECT_NAME/' .env | sed 's/FR_DOCKER_/DEFAULT_/')
	echo
fi

read -p "Port for XDebug [$DEFAULT_XDEBUG_PORT]: " xdebug_port
xdebug_port=$(validate_port $xdebug_port $DEFAULT_XDEBUG_PORT)

read -p "Port for Payments https [$DEFAULT_PAYMENTS_PORT]: " FR_DOCKER_PAYMENTS_PORT
FR_DOCKER_PAYMENTS_PORT=$(validate_port $FR_DOCKER_PAYMENTS_PORT $DEFAULT_PAYMENTS_PORT)

# allow setting of custom port for non-SSL (used when proxy does SSL termination)
read -p "Port for Payments http [$DEFAULT_PAYMENTS_HTTP_PORT]: " FR_DOCKER_PAYMENTS_HTTP_PORT
FR_DOCKER_PAYMENTS_HTTP_PORT=$(validate_port $FR_DOCKER_PAYMENTS_HTTP_PORT $DEFAULT_PAYMENTS_HTTP_PORT)

read -p "Port for Donut [$DEFAULT_DONUT_PORT]: " FR_DOCKER_DONUT_PORT
FR_DOCKER_DONUT_PORT=$(validate_port $FR_DOCKER_DONUT_PORT $DEFAULT_DONUT_PORT)

# allow setting of custom port for non-SSL (used for qunit tests with a headless browser)
read -p "Port for Donut http [$DEFAULT_DONUT_HTTP_PORT]: " FR_DOCKER_DONUT_HTTP_PORT
FR_DOCKER_DONUT_HTTP_PORT=$(validate_port $FR_DOCKER_DONUT_HTTP_PORT $DEFAULT_DONUT_HTTP_PORT)

# select one of the six test hostnames to forward
read -p "Which proxy forwarding ID would you like to use (1-6)? [$DEFAULT_PROXY_FORWARD_ID]: " FR_DOCKER_PROXY_FORWARD_ID
FR_DOCKER_PROXY_FORWARD_ID=${FR_DOCKER_PROXY_FORWARD_ID:-$DEFAULT_PROXY_FORWARD_ID}
while ! [[ $FR_DOCKER_PROXY_FORWARD_ID =~ ^[1-6]$ ]]; do
	read -p "Please enter a number 1-6: " FR_DOCKER_PROXY_FORWARD_ID
done

FR_DOCKER_CIVICRM_PORT=$DEFAULT_CIVICRM_PORT
echo "Port for Civicrm is currently not easily configurable. Set to $FR_DOCKER_CIVICRM_PORT."

FR_DOCKER_CIVIPROXY_PORT=$DEFAULT_CIVIPROXY_PORT
echo "Port for CiviProxy is currently fixed at $FR_DOCKER_CIVIPROXY_PORT."

read -p "Port for E-mail Preference Center https [$DEFAULT_EMAIL_PREF_CTR_PORT]: " \
	FR_DOCKER_EMAIL_PREF_CTR_PORT
FR_DOCKER_EMAIL_PREF_CTR_PORT=$(validate_port $FR_DOCKER_EMAIL_PREF_CTR_PORT $DEFAULT_EMAIL_PREF_CTR_PORT)

read -p "Port for SmashPig listener https [$DEFAULT_SMASHPIG_PORT]: " \
	FR_DOCKER_SMASHPIG_PORT
FR_DOCKER_SMASHPIG_PORT=$(validate_port $FR_DOCKER_SMASHPIG_PORT $DEFAULT_SMASHPIG_PORT)

read -p "Port for PrivateBin read-only https [$DEFAULT_PRIVATEBIN_RO_PORT]: " FR_DOCKER_PRIVATEBIN_RO_PORT
FR_DOCKER_PRIVATEBIN_RO_PORT=$(validate_port $FR_DOCKER_PRIVATEBIN_RO_PORT $DEFAULT_PRIVATEBIN_RO_PORT)

read -p "Port for PrivateBin read-write https [$DEFAULT_PRIVATEBIN_RW_PORT]: " FR_DOCKER_PRIVATEBIN_RW_PORT
FR_DOCKER_PRIVATEBIN_RW_PORT=$(validate_port $FR_DOCKER_PRIVATEBIN_RW_PORT $DEFAULT_PRIVATEBIN_RW_PORT)

read -p "Port for MariaDB connection [$DEFAULT_MARIADB_PORT]: " FR_DOCKER_MARIADB_PORT
FR_DOCKER_MARIADB_PORT=$(validate_port $FR_DOCKER_MARIADB_PORT $DEFAULT_MARIADB_PORT)

read -p "Port for SMTP [$DEFAULT_SMTP_PORT]: " FR_DOCKER_SMTP_PORT
FR_DOCKER_SMTP_PORT=$(validate_port $FR_DOCKER_SMTP_PORT $DEFAULT_SMTP_PORT)

read -p "Port for Mailcatcher [$DEFAULT_MAILCATCHER_PORT]: " FR_DOCKER_MAILCATCHER_PORT
FR_DOCKER_MAILCATCHER_PORT=$(validate_port $FR_DOCKER_MAILCATCHER_PORT $DEFAULT_MAILCATCHER_PORT)

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
FR_DOCKER_PAYMENTS_HTTP_PORT=${FR_DOCKER_PAYMENTS_HTTP_PORT}
FR_DOCKER_DONUT_PORT=${FR_DOCKER_DONUT_PORT}
FR_DOCKER_DONUT_HTTP_PORT=${FR_DOCKER_DONUT_HTTP_PORT}
FR_DOCKER_PROXY_FORWARD_ID=${FR_DOCKER_PROXY_FORWARD_ID}
FR_DOCKER_CIVICRM_PORT=${FR_DOCKER_CIVICRM_PORT}
FR_DOCKER_CIVIPROXY_PORT=${FR_DOCKER_CIVIPROXY_PORT}
FR_DOCKER_EMAIL_PREF_CTR_PORT=${FR_DOCKER_EMAIL_PREF_CTR_PORT}
FR_DOCKER_SMASHPIG_PORT=${FR_DOCKER_SMASHPIG_PORT}
FR_DOCKER_PRIVATEBIN_RO_PORT=${FR_DOCKER_PRIVATEBIN_RO_PORT}
FR_DOCKER_PRIVATEBIN_RW_PORT=${FR_DOCKER_PRIVATEBIN_RW_PORT}
FR_DOCKER_MARIADB_PORT=${FR_DOCKER_MARIADB_PORT}
FR_DOCKER_XDEBUG_PORT=${xdebug_port}
FR_DOCKER_UID=$(id -u)
FR_DOCKER_GID=$(id -g)
EOF

backup_mv /tmp/.env .env

cat .env
echo

echo "**** Creating or updating XDebug configurations"
cat << EOF > /tmp/default-xdebug2.ini
#### Customize xdebug settings here
#### Note: This file is automatically generated by setup.sh and is ignored by git, so
#### changes will not be tracked. For defaults, see setup.sh.
#### Note: remote_host, remote_log and remote_enable settings are set inside the container
#### from /srv/config/internal/xdebug-common.ini. However, they can be overriden here.

xdebug.remote_port=$xdebug_port
xdebug.remote_autostart=off
EOF

cat << EOF > /tmp/default-xdebug3.ini
#### Customize xdebug settings here
#### Note: This file is automatically generated by setup.sh and is ignored by git, so
#### changes will not be tracked. For defaults, see setup.sh.
#### Note: client_host, log and mode settings are set inside the container
#### from /srv/config/internal/xdebug-common.ini. However, they can be overriden here.

xdebug.client_port=$xdebug_port
xdebug.start_with_request=no
EOF

declare -a xdebug2_config_files=(
	"config/civicrm/xdebug-cli.ini"
	"config/civicrm/xdebug-web.ini"
	"config/email-pref-ctr/xdebug-cli.ini"
	"config/email-pref-ctr/xdebug-web.ini"
	"config/civiproxy/xdebug-cli.ini"
	"config/civiproxy/xdebug-web.ini"
	"config/smashpig/xdebug-cli.ini"
	"config/smashpig/xdebug-web.ini"
	"config/privatebin/xdebug-cli.ini"
	"config/privatebin/xdebug-web.ini"
)

for i in "${xdebug2_config_files[@]}"
do
	create_or_maybe_update_xdebug_ini 2 $i
done

declare -a xdebug3_config_files=(
	"config/payments/xdebug-cli.ini"
	"config/payments/xdebug-web.ini"
	"config/donut/xdebug-cli.ini"
	"config/donut/xdebug-web.ini"
)

for i in "${xdebug3_config_files[@]}"
do
	create_or_maybe_update_xdebug_ini 3 $i
done

echo

echo "**** Start application"
docker-compose up -d
echo

# Wait for db service

echo "**** Waiting for database to be ready"
while ! docker-compose exec payments \
	mysqladmin ping -h database -u root --silent > /dev/null; do
	sleep 0.5 && printf '.'
done
echo "Database ready"
echo

if [ $skip_install_dependencies = false ]; then

	echo "**** Composer"

	read -p "Payments: run composer install? [Yn] " -r
	if [[ $REPLY =~ ^[Yy]$ ]] || [ -z $REPLY ]; then
		# TODO put this in a separate script
		docker-compose exec -w "/var/www/html/" payments composer install
	fi
	echo

	read -p "Donut: run composer install? [Yn] " -r
	if [[ $REPLY =~ ^[Yy]$ ]] || [ -z $REPLY ]; then
		# TODO: need a composer.local.yaml to pull in the extension dependencies
		docker-compose exec -w "/var/www/html/w/" donut composer install
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

	read -p "Smashpig: run composer install? [Yn] " -r
	if [[ $REPLY =~ ^[Yy]$ ]] || [ -z $REPLY ]; then
		# TODO put this in a separate script
		docker-compose exec -w "/srv/smashpig" civicrm composer install
	fi
	echo

	read -p "Privatebin: run composer install? [Yn] " -r
	if [[ $REPLY =~ ^[Yy]$ ]] || [ -z $REPLY ]; then
		# TODO put this in a separate script
		docker-compose exec -w "/var/www/html" privatebin composer install
	fi
	echo

fi
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
		fi
		rm $localsettings_fn
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

echo "**** Donut: install.php, LocalSettings.php and update.php"

donut_install=true
localsettings_fn=src/${DONUT_SRC_DIR}/LocalSettings.php

# Prepare customized LocalSettings.php
	cat << EOF > /tmp/LocalSettings.php
<?php
require( '/srv/config/exposed/donut/LocalSettings.php');
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
		fi
		rm $localsettings_fn
	else
		donut_install=false
	fi
fi

if [ $donut_install = true ]; then
	echo "**** Running maintenance/install.php (cannot be run via run.php because LocalSettings is missing)"
	docker-compose exec -w "/var/www/html/w/" donut php maintenance/install.php \
		--server https://localhost:${FR_DOCKER_DONUT_PORT} \
		--dbname=donut \
		--dbuser=root \
		--dbserver=database \
		--lang=${MW_LANG} \
		--scriptpath="" \
		--pass=${MW_PASSWORD} Donut admin

	echo "Writing $localsettings_fn"
	mv /tmp/LocalSettings.php $localsettings_fn
	echo

	# Need to run update here to create all the tables for the extensions before importing the dump
	docker-compose exec -w "/var/www/html/w/" donut php maintenance/run.php update --quick

	echo "Importing dump from Donatewiki"
	gunzip -c config/donut/Donate.xml.gz | sed -e "s/payments.wikimedia.org/localhost:$FR_DOCKER_PAYMENTS_PORT/g" > config/donut/Donate-replaced.xml
	docker-compose exec -w "/var/www/html/w/" donut php maintenance/run.php importDump \
		/srv/config/exposed/donut/Donate-replaced.xml
	rm config/donut/Donate-replaced.xml
	# Set the Mainpage to Special:FundraiserRedirector
	docker-compose exec -T -w "/var/www/html/w/" \
		donut php maintenance/run.php edit MediaWiki:Mainpage < config/donut/MediaWiki_Mainpage.wiki
	# Add the admin user to the centralnoticeadmin group
	docker-compose exec -T -w "/var/www/html/w/" \
		donut php maintenance/run.php createAndPromote admin --force --custom-groups centralnoticeadmin
fi

# Ask about running update.php if we didn't run install.php
if [ $donut_install = false ]; then
  echo "**** maintenance/run.php update"
	read -p "Run update.php? [yN] " -r
	echo
	if [[ $REPLY =~ ^[Yy]$ ]]; then
		docker-compose exec -w "/var/www/html/w/" donut php maintenance/run.php update --quick
	fi
fi

echo

# TODO: Keep donatewiki content up to date via recentchanges API

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
		fi
		rm $localsettings_fn
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
	echo
fi

echo "**** Smashpig setup"

read -p "Create Smashpig database and db user? [Yn] " -r
echo

if [[ $REPLY =~ ^[Yy]$ ]] || [ -z $REPLY ]; then

	# Create SQL script
	cat << EOF > /tmp/smashpig_setup.sql
CREATE DATABASE IF NOT EXISTS smashpig;
use smashpig;
EOF

	cat src/smashpig/Schema/mysql/00[127]*.sql >> /tmp/smashpig_setup.sql

	cat << EOF >> /tmp/smashpig_setup.sql
CREATE USER IF NOT EXISTS 'smashpig'@'localhost' IDENTIFIED BY '$SMASHPIG_DB_USER_PASSWORD';
CREATE USER IF NOT EXISTS 'smashpig'@'%' IDENTIFIED BY '$SMASHPIG_DB_USER_PASSWORD';
GRANT ALL PRIVILEGES ON smashpig.* To 'smashpig'@'localhost';
GRANT ALL PRIVILEGES ON smashpig.* To 'smashpig'@'%';
EOF

	docker-compose exec -T civicrm mysql -u root -h database < /tmp/smashpig_setup.sql

	echo
fi


# go back to whatever directory we were in to start
cd "${start_dir}"


echo "Payments URL: https://localhost:$FR_DOCKER_PAYMENTS_PORT"
echo "Payments http URL: http://localhost:$FR_DOCKER_PAYMENTS_HTTP_PORT"
echo "Payments test routable URL: https://paymentstest$FR_DOCKER_PROXY_FORWARD_ID.wmcloud.org (see README.md)"
echo "Donut URL: https://localhost:$FR_DOCKER_DONUT_PORT/w/index.php/Special:FundraiserLandingPage?uselang=en&country=US"
echo "Donut http URL: http://localhost:$FR_DOCKER_DONUT_HTTP_PORT/w/index.php/Special:FundraiserLandingPage?uselang=en&country=US"
echo "WMF CiviCRM install URL: https://wmff.localhost:$FR_DOCKER_CIVICRM_PORT/civicrm"
echo "Generic CiviCRM install (based on upstream master) URL: https://dmaster.localhost:$FR_DOCKER_CIVICRM_PORT/civicrm"
echo "Civicrm user/password: admin/$CIVI_ADMIN_PASS"
echo "Mailcatcher - mails sent from CiviCRM core code: http://localhost:$FR_DOCKER_MAILCATCHER_PORT"
echo "CiviProxy URL: https://localhost:$FR_DOCKER_CIVIPROXY_PORT"
echo "SmashPig IPN listener routable URL: https://paymentsipntest$FR_DOCKER_PROXY_FORWARD_ID.wmcloud.org (see README.md)"
echo "E-mail Preference Center URL: https://localhost:$FR_DOCKER_EMAIL_PREF_CTR_PORT/index.php/Special:EmailPreferences"
echo "PrivateBin read-only URL: https://localhost:$FR_DOCKER_PRIVATEBIN_RO_PORT"
echo "PrivateBin read-write URL: https://localhost:$FR_DOCKER_PRIVATEBIN_RW_PORT"
echo
