#!/bin/bash
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}Running pending queue consumer${NC}"
docker-compose exec smashpig php /srv/smashpig/Maintenance/ConsumePendingQueue.php
echo -e "${BLUE}Running contribution tracking queue consumer${NC}"
docker-compose exec -w "/srv/civi-sites/wmff/drupal" civicrm drush @wmff -vv ctqc
echo -e "${BLUE}Running anti fraud queue consumer${NC}"
docker-compose exec -w "/srv/civi-sites/wmff/drupal" civicrm drush @wmff -vv afqc
echo -e "${BLUE}Running payment init queue consumer${NC}"
docker-compose exec -w "/srv/civi-sites/wmff/drupal" civicrm drush @wmff -vv piqc
echo -e "${BLUE}Running jobs-adyen queue consumer${NC}"
docker-compose exec smashpig php /srv/smashpig/Maintenance/QueueJobRunner.php --queue jobs-adyen --config-node adyen
echo -e "${BLUE}Running jobs-amazon queue consumer${NC}"
docker-compose exec smashpig php /srv/smashpig/Maintenance/QueueJobRunner.php --queue jobs-amazon --config-node amazon
echo -e "${BLUE}Running jobs-dlocal queue consumer${NC}"
docker-compose exec smashpig php /srv/smashpig/Maintenance/QueueJobRunner.php --queue jobs-dlocal --config-node dlocal
echo -e "${BLUE}Running jobs-ingenico queue consumer${NC}"
docker-compose exec smashpig php /srv/smashpig/Maintenance/QueueJobRunner.php --queue jobs-ingenico --config-node ingenico
echo -e "${BLUE}Running jobs-paypal queue consumer${NC}"
docker-compose exec smashpig php /srv/smashpig/Maintenance/QueueJobRunner.php --queue jobs-paypal --config-node paypal
echo -e "${BLUE}Running donations queue consumer${NC}"
docker-compose exec -w "/srv/civi-sites/wmff/drupal" civicrm drush @wmff -vv qc
echo -e "${BLUE}Running contribution tracking queue consumer${NC}"
docker-compose exec -w "/srv/civi-sites/wmff/drupal" civicrm drush @wmff -vv ctqc
echo -e "${BLUE}Running refunds queue consumer${NC}"
docker-compose exec -w "/srv/civi-sites/wmff/drupal" civicrm drush @wmff -vv rfdqc
echo -e "${BLUE}Running recurring queue consumer${NC}"
docker-compose exec -w "/srv/civi-sites/wmff/drupal" civicrm drush @wmff -vv rqc
echo -e "${BLUE}Running upi-donations queue consumer${NC}"
docker-compose exec -w "/srv/civi-sites/wmff/drupal" civicrm drush @wmff -vv cvapi UpiDonationsQueue.consume version=4
echo -e "${BLUE}Running preferences queue consumer${NC}"
docker-compose exec -w "/srv/civi-sites/wmff/drupal" civicrm drush @wmff -vv cvapi Preferencesqueue.consume version=3
echo -e "${BLUE}Running pending queue consumer${NC}"
docker-compose exec smashpig php /srv/smashpig/Maintenance/ConsumePendingQueue.php
