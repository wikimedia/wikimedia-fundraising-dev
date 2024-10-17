# DONUT Config
DONUT_SERVICE_NAME="donut"
DONUT_CONTAINER_DIR="/var/www/html/w"
DONUT_SRC_DIR="src/donut"
FUNDRAISING_EMAIL_UNSUBSCRIBE_EXT_DIR="$DONUT_SRC_DIR/extensions/FundraisingEmailUnsubscribe"
MW_CORE_BRANCH="fundraising/REL1_39"
MW_LANG="en"
MW_USER="admin"
MW_PASSWORD="dockerpass"

echo
echo "**** Clone Donut wiki"
# clone and configure git repos
if $(ask_reclone $DONUT_SRC_DIR "Donut wiki repo"); then

  rm -rf "${DONUT_SRC_DIR:?}"/*
  find "${DONUT_SRC_DIR:?}" -mindepth 1 -name '.*' -exec rm -rf {} +

  # Clone donut with gerrit hooks
  git clone "ssh://${GIT_REVIEW_USER}@gerrit.wikimedia.org:29418/mediawiki/core" \
    --depth=10 --no-single-branch \
    $DONUT_SRC_DIR &&
    (
      cd "$DONUT_SRC_DIR" &&
        mkdir -p $(git rev-parse --git-dir)/hooks/ &&
        curl -Lo $(git rev-parse --git-dir)/hooks/commit-msg \
          https://gerrit.wikimedia.org/r/tools/hooks/commit-msg
      chmod +x $(git rev-parse --git-dir)/hooks/commit-msg
    )

		cat << EOF >> ${DONUT_SRC_DIR}/composer.local.json
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

  pushd ${DONUT_SRC_DIR}/extensions
    # Loop over donut wiki extensions and clone
    for i in CentralNotice CodeEditor CodeMirror EventLogging FundraiserLandingPage FundraisingTranslateWorkflow LandingCheck Linter MobileFrontend ParserFunctions Scribunto TemplateSandbox TemplateStyles Translate UniversalLanguageSelector WikiEditor
		do
			git clone "ssh://${GIT_REVIEW_USER}@gerrit.wikimedia.org:29418/mediawiki/extensions/$i" \
				--depth=10 --no-single-branch && \
			scp $EXTRA_SCP_OPTION -p -P 29418 ${GIT_REVIEW_USER}@gerrit.wikimedia.org:hooks/commit-msg \
			"$i/.git/hooks/"

      git clone "ssh://${GIT_REVIEW_USER}@gerrit.wikimedia.org:29418/mediawiki/extensions/$i" \
      --depth=10 --no-single-branch \
      ${DONUT_SRC_DIR}/extensions/$i &&
      (
        cd "${DONUT_SRC_DIR}/extensions/$i" &&
          mkdir -p $(git rev-parse --git-dir)/hooks/ &&
          curl -Lo $(git rev-parse --git-dir)/hooks/commit-msg \
            https://gerrit.wikimedia.org/r/tools/hooks/commit-msg
        chmod +x $(git rev-parse --git-dir)/hooks/commit-msg
      )
		done
  popd

  pushd ${DONUT_SRC_DIR}/skins

  git clone "ssh://${GIT_REVIEW_USER}@gerrit.wikimedia.org:29418/mediawiki/skins/Vector" \
    --depth=10 --no-single-branch && \
    (
      cd "Vector" &&
        mkdir -p $(git rev-parse --git-dir)/hooks/ &&
        curl -Lo $(git rev-parse --git-dir)/hooks/commit-msg \
          https://gerrit.wikimedia.org/r/tools/hooks/commit-msg
      chmod +x $(git rev-parse --git-dir)/hooks/commit-msg
    )

  git clone "ssh://${GIT_REVIEW_USER}@gerrit.wikimedia.org:29418/mediawiki/skins/MinervaNeue" \
    --depth=10 --no-single-branch && \
    (
      cd "MinervaNeue" &&
        mkdir -p $(git rev-parse --git-dir)/hooks/ &&
        curl -Lo $(git rev-parse --git-dir)/hooks/commit-msg \
          https://gerrit.wikimedia.org/r/tools/hooks/commit-msg
      chmod +x $(git rev-parse --git-dir)/hooks/commit-msg
    )

  popd
fi

# bring up docker container
docker_compose_up "$DOCKER_COMPOSE_FILE"  "$DONUT_SERVICE_NAME"

echo "**** Install Donut wiki "

# Composer install
read -p "Run Donut wiki Composer install? [yN] " -r
if [[ $REPLY =~ ^[Yy]$ ]]; then
  $DOCKER_COMPOSE_COMMAND_BASE exec -w ${DONUT_CONTAINER_DIR} ${DONUT_SERVICE_NAME} composer install
fi
echo

donut_install=true
localsettings_fn=${DONUT_SRC_DIR}/LocalSettings.php
# Prepare customized LocalSettings.php
cat <<EOF >/tmp/LocalSettings.php
<?php
require( '/srv/config/exposed/donut/LocalSettings.php');
EOF

if [[ -e $localsettings_fn ]]; then
  read -p "Set up a fresh Donut wiki LocalSettings.php? [yN] " -r
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

read -p "Run Donut wiki maintenance/install.php [yN] " -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
  $DOCKER_COMPOSE_COMMAND_BASE exec -w ${DONUT_CONTAINER_DIR} ${DONUT_SERVICE_NAME} php maintenance/install.php \
    --server https://localhost:${DONUT_PORT} \
    --dbname=donut \
    --dbuser=root \
    --dbserver=database \
    --lang=${MW_LANG} \
    --scriptpath="" \
    --pass=${MW_PASSWORD} Donut ${MW_USER}

  echo "Writing $localsettings_fn"
  mv /tmp/LocalSettings.php $localsettings_fn
  echo
fi

donut_update=true

# Only ask about running update.php if we didn't run install.php; otherwise we have to run it.
if [ $donut_install = false ]; then
  read -p "Run Donut wiki maintenance/update.php? [yN] " -r
  echo
  if ! [[ $REPLY =~ ^[Yy]$ ]]; then
    donut_update=false
  fi
fi

if [ $donut_update = true ]; then
  $DOCKER_COMPOSE_COMMAND_BASE exec -w ${DONUT_CONTAINER_DIR} donut php maintenance/update.php --quick
fi

read -p "Import content dump from Donatewiki? [yN] " -r
if [[ $REPLY =~ ^[Yy]$ ]]; then
  echo "Importing dump from Donatewiki"
  gunzip -c config/donut/Donate.xml.gz | sed -e "s/payments.wikimedia.org/localhost:$PAYMENTS_PORT/g" > config/donut/Donate-replaced.xml
  $DOCKER_COMPOSE_COMMAND_BASE exec -w "/var/www/html/w/" donut php maintenance/run.php importDump \
    /srv/config/exposed/donut/Donate-replaced.xml
  rm config/donut/Donate-replaced.xml
fi
echo

# Set the Mainpage to Special:FundraiserRedirector
$DOCKER_COMPOSE_COMMAND_BASE exec -T -w "/var/www/html/w/" \
  donut php maintenance/run.php edit MediaWiki:Mainpage < config/donut/MediaWiki_Mainpage.wiki
# Add the admin user to the centralnoticeadmin group
$DOCKER_COMPOSE_COMMAND_BASE exec -T -w "/var/www/html/w/" \
  donut php maintenance/run.php createAndPromote admin --force --custom-groups centralnoticeadmin

echo
echo "Donate/Donut Wiki URL: https://localhost:$DONUT_PORT/w/index.php/Special:FundraiserLandingPage?uselang=en&country=US"
echo "Donate/Donut Wiki HTTP URL: http://localhost:$DONUT_HTTP_PORT/w/index.php/Special:FundraiserLandingPage?uselang=en&country=US"
echo
echo "Donate/Donut Wiki Central Notice Login: $MW_USER:$MW_PASSWORD"
echo "Donate/Donut Wiki Central Notice URL: https://localhost:$DONUT_PORT/w/index.php?title=Special:UserLogin&returnto=Special:CentralNotice"