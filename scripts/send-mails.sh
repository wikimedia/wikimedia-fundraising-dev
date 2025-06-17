#!/bin/bash
BLUE='\033[1;34m'
GREEN='\033[1;32m'
NC='\033[0m' # No Color

echo -e "${BLUE}Send ${GREEN}thank you${BLUE} mail${NC}"
docker compose exec -w "/srv/civi-sites/wmf" civicrm wmf-cv -vv api4 ThankYou.BatchSend numberOfDays=2
echo -e "${BLUE}Send ${GREEN}eoy${BLUE} mail${NC}"
docker compose exec -w "/srv/civi-sites/wmf" civicrm wmf-cv -vv api4 EOYEmail.Send limit=5000 timeLimit=840
