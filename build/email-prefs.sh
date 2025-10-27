# EMAIL_PREF_CTR Config
EMAIL_PREF_CTR_SERVICE_NAME="email-pref-ctr"
EMAIL_PREF_CTR_CONTAINER_DIR="/var/www/html"
EMAIL_PREF_CTR_SRC_DIR="src/email-pref-ctr"
DONATION_INTERFACE_EXT_DIR="$EMAIL_PREF_CTR_SRC_DIR/extensions/DonationInterface"
MW_CORE_BRANCH="fundraising/REL1_43"
MW_LANG="en"
MW_USER="admin"
MW_PASSWORD="dockerpass"

echo
echo "**** Clone E-mail Preference Center wiki"
# clone and configure git repos
if $(ask_reclone $EMAIL_PREF_CTR_SRC_DIR "E-mail Preference Center wiki repo"); then
  
  rm -rf "${EMAIL_PREF_CTR_SRC_DIR:?}"/*
  find "${EMAIL_PREF_CTR_SRC_DIR:?}" -mindepth 1 -name '.*' -exec rm -rf {} +

  # Clone email-pref-ctr with gerrit hooks
  git clone "ssh://${GIT_REVIEW_USER}@gerrit.wikimedia.org:29418/mediawiki/core" \
    --depth=10 --no-single-branch \
    $EMAIL_PREF_CTR_SRC_DIR &&
    (
      cd "$EMAIL_PREF_CTR_SRC_DIR" &&
        mkdir -p $(git rev-parse --git-dir)/hooks/ &&
        curl -Lo $(git rev-parse --git-dir)/hooks/commit-msg \
          https://gerrit.wikimedia.org/r/tools/hooks/commit-msg
      chmod +x $(git rev-parse --git-dir)/hooks/commit-msg
    )

  pushd $EMAIL_PREF_CTR_SRC_DIR
    git checkout --track remotes/origin/${MW_CORE_BRANCH}
    git submodule update --init --recursive
  popd

  pushd $DONATION_INTERFACE_EXT_DIR
    git checkout master
  popd
fi

# bring up docker container
docker_compose_up "$DOCKER_COMPOSE_FILE"  "$EMAIL_PREF_CTR_SERVICE_NAME"

echo "**** Install E-mail Preference Center wiki "

# Composer install
read -p "Run E-mail Preference Center wiki Composer install? [yN] " -r
if [[ $REPLY =~ ^[Yy]$ ]]; then
  $DOCKER_COMPOSE_COMMAND_BASE exec -w ${EMAIL_PREF_CTR_CONTAINER_DIR} ${EMAIL_PREF_CTR_SERVICE_NAME} composer install
fi
echo

email_pref_ctr_install=true
localsettings_fn=${EMAIL_PREF_CTR_SRC_DIR}/LocalSettings.php
# Prepare customized LocalSettings.php
cat <<EOF >/tmp/LocalSettings.php
<?php
require( '/srv/config/exposed/email-pref-ctr/LocalSettings.php');
EOF

if [[ -e $localsettings_fn ]]; then
  read -p "Set up a fresh E-mail Preference Center wiki LocalSettings.php? [yN] " -r
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

read -p "Run E-mail Preference Center wiki maintenance/install.php [yN] " -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
  $DOCKER_COMPOSE_COMMAND_BASE exec -w ${EMAIL_PREF_CTR_CONTAINER_DIR} ${EMAIL_PREF_CTR_SERVICE_NAME} php maintenance/install.php \
    --server https://localhost:${EMAIL_PREF_CTR_PORT} \
    --dbname=email-pref-ctr \
    --dbuser=root \
    --dbserver=database \
    --lang=${MW_LANG} \
    --scriptpath="" \
    --pass=${MW_PASSWORD} "E-mail Preference Center" ${MW_USER}

  echo "Writing $localsettings_fn"
  mv /tmp/LocalSettings.php $localsettings_fn
  echo
fi

email_pref_ctr_update=true

# Only ask about running update.php if we didn't run install.php; otherwise we have to run it.
if [ $email_pref_ctr_install = false ]; then
  read -p "Run E-mail Preference Center wiki maintenance/update.php? [yN] " -r
  echo
  if ! [[ $REPLY =~ ^[Yy]$ ]]; then
    email_pref_ctr_update=false
  fi
fi

if [ $email_pref_ctr_update = true ]; then
  $DOCKER_COMPOSE_COMMAND_BASE exec -w "/var/www/html/" ${EMAIL_PREF_CTR_SERVICE_NAME} php maintenance/update.php --quick
fi
echo

echo "Donor Portal URL: https://localhost:$EMAIL_PREF_CTR_PORT/index.php/Special:EmailPreferences"
echo "Donor Portal contact page: Viewable within local CiviCRM https://wmf.localhost:32353/civicrm/contact/view?reset=1&cid=32"
echo "E-mail Preference Center URL: Viewable within local CiviCRM https://wmf.localhost:32353/civicrm/contact/view?reset=1&cid=32"
