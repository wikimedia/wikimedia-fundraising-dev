DJANGO_BANNER_STATS_SRC_DIR="src/django-banner-stats"
DJANGO_BANNER_STATS_SERVICE_NAME="djangobannerstats"
DB_SERVICE_NAME="database"

echo "**** Clone DjangoBannerStats"
clone_stats=$(ask_reclone "${DJANGO_BANNER_STATS_SRC_DIR}" "DjangoBannerStats repo")
if [ $clone_stats = true ]; then
  echo "**** Cloning and setting up DjangoBannerStats repo in ${DJANGO_BANNER_STATS_SRC_DIR}"

  rm -rf ${DJANGO_BANNER_STATS_SRC_DIR:?}
  mkdir -p src/

  git clone "ssh://${GIT_REVIEW_USER}@gerrit.wikimedia.org:29418/wikimedia/fundraising/tools/DjangoBannerStats" \
    ${DJANGO_BANNER_STATS_SRC_DIR} && \
    (cd "$DJANGO_BANNER_STATS_SRC_DIR" && \
    mkdir -p `git rev-parse --git-dir`/hooks/ && \
    curl -Lo `git rev-parse --git-dir`/hooks/commit-msg \
    https://gerrit.wikimedia.org/r/tools/hooks/commit-msg; \
    chmod +x `git rev-parse --git-dir`/hooks/commit-msg)
fi

$DOCKER_COMPOSE_COMMAND_BASE up --force-recreate -d "$DJANGO_BANNER_STATS_SERVICE_NAME"

echo
echo "Install required Python3 packages"
echo
$DOCKER_COMPOSE_COMMAND_BASE exec ${DJANGO_BANNER_STATS_SERVICE_NAME} mkdir -p /srv/django-banner-stats/packages
$DOCKER_COMPOSE_COMMAND_BASE exec ${DJANGO_BANNER_STATS_SERVICE_NAME} pip3 install "Django==1.11.29" -t /srv/django-banner-stats/packages
$DOCKER_COMPOSE_COMMAND_BASE exec ${DJANGO_BANNER_STATS_SERVICE_NAME} pip3 install "PyMySQL==0.9.3" -t /srv/django-banner-stats/packages
$DOCKER_COMPOSE_COMMAND_BASE exec ${DJANGO_BANNER_STATS_SERVICE_NAME} pip3 install "mysqlclient==1.3.14" -t /srv/django-banner-stats/packages
echo
echo "Python3 Packages installed!"
echo

read -p "Create DjangoBannerStats database? [Yn] " -r
echo
if [[ $REPLY =~ ^[Yy]$ ]] || [ -z $REPLY ]; then
	$DOCKER_COMPOSE_COMMAND_BASE exec -T ${DB_SERVICE_NAME} mysql -e "CREATE DATABASE IF NOT EXISTS dev_pgehres;"
	echo "Added dev_pgehres database..."
	$DOCKER_COMPOSE_COMMAND_BASE exec -T ${DB_SERVICE_NAME} mysql dev_pgehres < src/django-banner-stats/doc/001_create.sql
	echo "Imported src/django-banner-stats/doc/001_create.sql"
	$DOCKER_COMPOSE_COMMAND_BASE exec -T ${DB_SERVICE_NAME} mysql dev_pgehres < src/django-banner-stats/doc/002_populate_countries.sql
	echo "Imported src/django-banner-stats/doc/002_populate_countries.sql"
	$DOCKER_COMPOSE_COMMAND_BASE exec -T ${DB_SERVICE_NAME} mysql dev_pgehres < src/django-banner-stats/doc/003_populate_languages.sql
	echo "Imported src/django-banner-stats/doc/003_populate_languages.sql"
	echo "Finished setting up DjangoBannerStats database..."
fi

echo
echo "**** DjangoBannerStats setup complete"
echo
echo "You can test it by connecting into the container and running:"
echo "python3 /srv/django-banner-stats/manage.py LoadLPImpressions --verbose --recent"
echo "python3 /srv/django-banner-stats/manage.py LoadBannerImpressions2Aggregate --verbose --top --recent"
