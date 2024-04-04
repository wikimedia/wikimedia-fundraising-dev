#!/bin/bash
BLUE='\033[1;34m'
GREEN='\033[1;32m'
NC='\033[0m' # No Color

echo -e "${BLUE}Running ${GREEN}anti fraud${BLUE} queue consumer${NC}"
docker compose exec -w "/srv/civi-sites/wmff/drupal" civicrm drush @wmff -vv afqc 2>&1 | tail -n +23

echo -e "${BLUE}Running ${GREEN}payment init${BLUE} queue consumer${NC}"
docker compose exec -w "/srv/civi-sites/wmff/drupal" civicrm drush @wmff -vv piqc 2>&1 | tail -n +23

echo -e "${BLUE}Running ${GREEN}donations${BLUE} queue consumer${NC}"
docker compose exec -w "/srv/civi-sites/wmff/drupal" civicrm drush @wmff -vv qc 2>&1 | tail -n +23

echo -e "${BLUE}Running ${GREEN}contribution tracking${BLUE} queue consumer${NC}"
docker compose exec -w "/srv/civi-sites/wmff/drupal" civicrm drush @wmff -vv ctqc 2>&1 | tail -n +23

echo -e "${BLUE}Running ${GREEN}refunds${BLUE} queue consumer${NC}"
docker compose exec -w "/srv/civi-sites/wmff/drupal" civicrm drush @wmff -vv rfdqc 2>&1 | tail -n +23

echo -e "${BLUE}Running ${GREEN}recurring${BLUE} queue consumer${NC}"
docker compose exec -w "/srv/civi-sites/wmff/drupal" civicrm cv api4 --user=admin -vv WMFQueue.Consume timeLimit=280 queueConsumer=Recurring queueName=recurring 2>&1 | tail -n +18

echo -e "${BLUE}Running ${GREEN}recurring-upgrade${BLUE} queue consumer${NC}"
docker compose exec -w "/srv/civi-sites/wmff/drupal" civicrm cv api4 --user=admin -vv WMFQueue.Consume timeLimit=280 queueConsumer=RecurringModifyAmount queueName=recurring-upgrade 2>&1 | tail -n +18

echo -e "${BLUE}Running ${GREEN}upi-donations${BLUE} queue consumer${NC}"
docker compose exec -w "/srv/civi-sites/wmff/drupal" civicrm cv api4 --user=admin -vv WMFQueue.Consume timeLimit=280 queueConsumer=UpiDonations queueName=upi-donations 2>&1 | tail -n +18

echo -e "${BLUE}Running ${GREEN}preferences${BLUE} queue consumer${NC}"
docker compose exec -w "/srv/civi-sites/wmff/drupal" civicrm cv api4 --user=admin -vv WMFQueue.Consume timeLimit=280 queueConsumer=EmailPreferences queueName=email-preferences 2>&1 | tail -n +18

echo -e "${BLUE}Running ${GREEN}opt-in${BLUE} queue consumer${NC}"
docker compose exec -w "/srv/civi-sites/wmff/drupal" civicrm cv api4 --user=admin -vv WMFQueue.Consume timeLimit=280 queueConsumer=OptIn queueName=opt-in 2>&1 | tail -n +18

echo -e "${BLUE}Running ${GREEN}unsubscribe${BLUE} queue consumer${NC}"
docker compose exec -w "/srv/civi-sites/wmff/drupal" civicrm drush @wmff -vv unsubqc 2>&1 | tail -n +23

echo -e "${BLUE}Running ${GREEN}banner history${BLUE} queue consumer${NC}"
docker compose exec -w "/srv/civi-sites/wmff/drupal" civicrm cv api4 --user=admin -vv WMFQueue.Consume timeLimit=280 queueConsumer=BannerHistory queueName=banner-history 2>&1 | tail -n +18
