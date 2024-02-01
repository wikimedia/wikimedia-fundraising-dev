#!/bin/bash
BLUE='\033[1;34m'
GREEN='\033[1;32m'
NC='\033[0m' # No Color

echo -e "${BLUE}Create IPN from pendingTable for ${GREEN}ingenico${BLUE}${NC}"
docker compose exec -w "/srv/civi-sites/wmff/drupal" civicrm drush @wmff -vv cvapi PendingTable.consume version=4 gateway=ingenico timeLimit=1500
echo -e "${BLUE}Create IPN from pendingTable for ${GREEN}adyen${BLUE}${NC}"
docker compose exec -w "/srv/civi-sites/wmff/drupal" civicrm drush @wmff -vv cvapi PendingTable.consume version=4 gateway=adyen timeLimit=1500
echo -e "${BLUE}Create IPN from pendingTable for ${GREEN}paypal_ec${BLUE}${NC}"
docker compose exec -w "/srv/civi-sites/wmff/drupal" civicrm drush @wmff -vv cvapi PendingTable.consume version=4 gateway=paypal_ec timeLimit=1500
echo -e "${BLUE}Create IPN from pendingTable for ${GREEN}dlocal${BLUE}${NC}"
docker compose exec -w "/srv/civi-sites/wmff/drupal" civicrm drush @wmff -vv cvapi PendingTable.consume version=4 gateway=dlocal timeLimit=1500