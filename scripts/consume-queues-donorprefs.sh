#!/bin/bash
BLUE='\033[1;34m'
GREEN='\033[1;32m'
NC='\033[0m' # No Color

echo -e "${BLUE}Running ${GREEN}preferences${BLUE} queue consumer${NC}"
docker compose exec -w "/srv/civi-sites/wmf" civicrm cv api4 --user=admin -vv WMFQueue.Consume timeLimit=280 queueConsumer=EmailPreferences queueName=email-preferences 2>&1 | tail -n +18

echo -e "${BLUE}Running ${GREEN}opt-in${BLUE} queue consumer${NC}"
docker compose exec -w "/srv/civi-sites/wmf" civicrm cv api4 --user=admin -vv WMFQueue.Consume timeLimit=280 queueConsumer=OptIn queueName=opt-in 2>&1 | tail -n +18

echo -e "${BLUE}Running ${GREEN}unsubscribe${BLUE} queue consumer${NC}"
docker compose exec -w "/srv/civi-sites/wmf" civicrm cv api4 --user=admin -vv WMFQueue.Consume timeLimit=280 queueConsumer=Unsubscribe queueName=unsubscribe 2>&1 | tail -n +18

echo -e "${BLUE}Running ${GREEN}new-checksum-link${BLUE} queue consumer${NC}"
docker compose exec -w "/srv/civi-sites/wmf" civicrm cv api4 --user=admin -vv WMFQueue.Consume timeLimit=280 queueConsumer=NewChecksumLink queueName=new-checksum-link 2>&1 | tail -n +18

echo -e "${BLUE}Running ${GREEN}set-primary-email${BLUE} queue consumer${NC}"
docker compose exec -w "/srv/civi-sites/wmf" civicrm cv api4 --user=admin -vv WMFQueue.Consume timeLimit=280 queueConsumer=SetPrimaryEmail queueName=set-primary-email 2>&1 | tail -n +18
