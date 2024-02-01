#!/bin/bash
BLUE='\033[1;34m'
GREEN='\033[1;32m'
NC='\033[0m' # No Color

echo -e "${BLUE}Send ${GREEN}thank you${BLUE} mail${NC}"
docker compose exec -w "/srv/civi-sites/wmff/drupal" civicrm drush @wmff -vv thank-you-send --days=1
echo -e "${BLUE}Send ${GREEN}eoy${BLUE} mail${NC}"
docker compose exec -w "/srv/civi-sites/wmff/drupal" civicrm drush @wmff -vv cvapi EOYEmail.Send version=4 limit=5000 timeLimit=840