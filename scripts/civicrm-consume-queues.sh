#!/bin/bash
BLUE='\033[1;34m'
GREEN='\033[1;32m'
NC='\033[0m' # No Color

echo -e "${BLUE}Running ${GREEN}pending${BLUE} queue consumer${NC}"
docker compose exec smashpig php /srv/smashpig/Maintenance/ConsumePendingQueue.php
echo -e "${BLUE}Running ${GREEN}anti fraud${BLUE} queue consumer${NC}"
docker compose exec -w "/srv/civi-sites/wmff/drupal" civicrm drush @wmff -vv afqc 2>&1 | tail -n +23
echo -e "${BLUE}Running ${GREEN}payment init${BLUE} queue consumer${NC}"
docker compose exec -w "/srv/civi-sites/wmff/drupal" civicrm drush @wmff -vv piqc 2>&1 | tail -n +23
echo -e "${BLUE}Running ${GREEN}jobs-adyen${BLUE} queue consumer${NC}"
docker compose exec smashpig php /srv/smashpig/Maintenance/QueueJobRunner.php --queue jobs-adyen --config-node adyen
echo -e "${BLUE}Running ${GREEN}jobs-amazon${BLUE} queue consumer${NC}"
docker compose exec smashpig php /srv/smashpig/Maintenance/QueueJobRunner.php --queue jobs-amazon --config-node amazon
echo -e "${BLUE}Running ${GREEN}jobs-dlocal${BLUE} queue consumer${NC}"
docker compose exec smashpig php /srv/smashpig/Maintenance/QueueJobRunner.php --queue jobs-dlocal --config-node dlocal
echo -e "${BLUE}Running ${GREEN}jobs-ingenico${BLUE} queue consumer${NC}"
docker compose exec smashpig php /srv/smashpig/Maintenance/QueueJobRunner.php --queue jobs-ingenico --config-node ingenico
echo -e "${BLUE}Running ${GREEN}jobs-paypal${BLUE} queue consumer${NC}"
docker compose exec smashpig php /srv/smashpig/Maintenance/QueueJobRunner.php --queue jobs-paypal --config-node paypal
echo -e "${BLUE}Running ${GREEN}donations${BLUE} queue consumer${NC}"
docker compose exec -w "/srv/civi-sites/wmff/drupal" civicrm drush @wmff -vv qc 2>&1 | tail -n +23
echo -e "${BLUE}Running ${GREEN}contribution tracking${BLUE} queue consumer${NC}"
docker compose exec -w "/srv/civi-sites/wmff/drupal" civicrm drush @wmff -vv ctqc 2>&1 | tail -n +23
echo -e "${BLUE}Running ${GREEN}refunds${BLUE} queue consumer${NC}"
docker compose exec -w "/srv/civi-sites/wmff/drupal" civicrm drush @wmff -vv rfdqc 2>&1 | tail -n +23
echo -e "${BLUE}Running ${GREEN}recurring${BLUE} queue consumer${NC}"
docker compose exec -w "/srv/civi-sites/wmff/drupal" civicrm drush @wmff -vv rqc 2>&1 | tail -n +23
echo -e "${BLUE}Running ${GREEN}recurring-upgrade${BLUE} queue consumer${NC}"
docker compose exec -w "/srv/civi-sites/wmff/drupal" civicrm drush @wmff -vv rqc --queue=recurring-upgrade 2>&1 | tail -n +23
echo -e "${BLUE}Running ${GREEN}upi-donations${BLUE} queue consumer${NC}"
docker compose exec -w "/srv/civi-sites/wmff/drupal" civicrm drush @wmff -vv cvapi UpiDonationsQueue.consume version=4 2>&1 | tail -n +23
echo -e "${BLUE}Running ${GREEN}preferences${BLUE} queue consumer${NC}"
docker compose exec -w "/srv/civi-sites/wmff/drupal" civicrm drush @wmff -vv cvapi Preferencesqueue.consume version=3 2>&1 | tail -n +23
echo -e "${BLUE}Running ${GREEN}opt-in${BLUE} queue consumer${NC}"
docker compose exec -w "/srv/civi-sites/wmff/drupal" civicrm drush @wmff -vv oqc 2>&1 | tail -n +23
echo -e "${BLUE}Running ${GREEN}unsubscribe${BLUE} queue consumer${NC}"
docker compose exec -w "/srv/civi-sites/wmff/drupal" civicrm drush @wmff -vv unsubqc 2>&1 | tail -n +23
echo -e "${BLUE}Running ${GREEN}banner history${BLUE} queue consumer${NC}"
docker compose exec -w "/srv/civi-sites/wmff/drupal" civicrm drush @wmff -vv bhqc 2>&1 | tail -n +23
