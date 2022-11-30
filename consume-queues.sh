#!/bin/bash
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}Running anti fraud queue consumer${NC}"
docker-compose exec -w "/srv/civi-sites/wmff/drupal" civicrm drush -v afqc
echo -e "${BLUE}Running contribution tracking queue consumer${NC}"
docker-compose exec -w "/srv/civi-sites/wmff/drupal" civicrm drush -v ctqc
echo -e "${BLUE}Running payment init queue consumer${NC}"
docker-compose exec -w "/srv/civi-sites/wmff/drupal" civicrm drush -v piqc
echo -e "${BLUE}Running donations queue consumer${NC}"
docker-compose exec -w "/srv/civi-sites/wmff/drupal" civicrm drush -v qc
echo -e "${BLUE}Running contribution tracking queue consumer${NC}"
docker-compose exec -w "/srv/civi-sites/wmff/drupal" civicrm drush -v ctqc
echo -e "${BLUE}Running refunds queue consumer${NC}"
docker-compose exec -w "/srv/civi-sites/wmff/drupal" civicrm drush -v rfdqc
echo -e "${BLUE}Running recurring queue consumer${NC}"
docker-compose exec -w "/srv/civi-sites/wmff/drupal" civicrm drush -v rqc
echo -e "${BLUE}Running pending queue consumer${NC}"
docker-compose exec smashpig php /srv/smashpig/Maintenance/ConsumePendingQueue.php
