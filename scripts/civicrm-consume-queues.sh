#!/bin/bash
BLUE='\033[1;34m'
GREEN='\033[1;32m'
NC='\033[0m' # No Color

echo -e "${BLUE}Running ${GREEN}pending${BLUE} queue consumer${NC}"
docker-compose exec smashpig php /srv/smashpig/Maintenance/ConsumePendingQueue.php
echo -e "${BLUE}Running ${GREEN}anti fraud${BLUE} queue consumer${NC}"
docker-compose exec -w "/srv/civi-sites/wmff/drupal" civicrm drush @wmff -vv afqc
echo -e "${BLUE}Running ${GREEN}payment init${BLUE} queue consumer${NC}"
docker-compose exec -w "/srv/civi-sites/wmff/drupal" civicrm drush @wmff -vv piqc
echo -e "${BLUE}Running ${GREEN}jobs-adyen${BLUE} queue consumer${NC}"
docker-compose exec smashpig php /srv/smashpig/Maintenance/QueueJobRunner.php --queue jobs-adyen --config-node adyen
echo -e "${BLUE}Running ${GREEN}jobs-amazon${BLUE} queue consumer${NC}"
docker-compose exec smashpig php /srv/smashpig/Maintenance/QueueJobRunner.php --queue jobs-amazon --config-node amazon
echo -e "${BLUE}Running ${GREEN}jobs-dlocal${BLUE} queue consumer${NC}"
docker-compose exec smashpig php /srv/smashpig/Maintenance/QueueJobRunner.php --queue jobs-dlocal --config-node dlocal
echo -e "${BLUE}Running ${GREEN}jobs-ingenico${BLUE} queue consumer${NC}"
docker-compose exec smashpig php /srv/smashpig/Maintenance/QueueJobRunner.php --queue jobs-ingenico --config-node ingenico
echo -e "${BLUE}Running ${GREEN}jobs-paypal${BLUE} queue consumer${NC}"
docker-compose exec smashpig php /srv/smashpig/Maintenance/QueueJobRunner.php --queue jobs-paypal --config-node paypal
echo -e "${BLUE}Running ${GREEN}donations${BLUE} queue consumer${NC}"
docker-compose exec -w "/srv/civi-sites/wmff/drupal" civicrm drush @wmff -vv qc
echo -e "${BLUE}Running ${GREEN}contribution tracking${BLUE} queue consumer${NC}"
docker-compose exec -w "/srv/civi-sites/wmff/drupal" civicrm drush @wmff -vv ctqc
echo -e "${BLUE}Running ${GREEN}refunds${BLUE} queue consumer${NC}"
docker-compose exec -w "/srv/civi-sites/wmff/drupal" civicrm drush @wmff -vv rfdqc
echo -e "${BLUE}Running ${GREEN}recurring${BLUE} queue consumer${NC}"
docker-compose exec -w "/srv/civi-sites/wmff/drupal" civicrm drush @wmff -vv rqc
echo -e "${BLUE}Running ${GREEN}recurring-upgrade${BLUE} queue consumer${NC}"
docker-compose exec -w "/srv/civi-sites/wmff/drupal" civicrm drush @wmff -vv rqc --queue=recurring-upgrade
echo -e "${BLUE}Running ${GREEN}upi-donations${BLUE} queue consumer${NC}"
docker-compose exec -w "/srv/civi-sites/wmff/drupal" civicrm drush @wmff -vv cvapi UpiDonationsQueue.consume version=4
echo -e "${BLUE}Running ${GREEN}preferences${BLUE} queue consumer${NC}"
docker-compose exec -w "/srv/civi-sites/wmff/drupal" civicrm drush @wmff -vv cvapi Preferencesqueue.consume version=3
