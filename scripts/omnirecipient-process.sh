#!/bin/bash
BLUE='\033[1;34m'
GREEN='\033[1;32m'
NC='\033[0m' # No Color

#retrieve mailing data and store to civicrm_mailing_provider_data
echo -e "${BLUE}Running ${GREEN}Omnirecipient unsubscribe${BLUE}${NC}"
docker compose exec -w "/srv/civi-sites/wmf" civicrm wmf-cv -vv --in=json api3 Omnirecipient.load
#process from civicrm_mailing_provider_data to create unsubscribe activities.
echo -e "${BLUE}Running ${GREEN}Omnirecipient unsubscribe${BLUE}${NC}"
docker compose exec -w "/srv/civi-sites/wmf" civicrm wmf-cv -vv api3 Omnirecipient.process_unsubscribes mail_provider=Silverpop rowCount=5000
#Manage omnimail job to issue deletion requests for Silverpop.
echo -e "${BLUE}Running ${GREEN}Omnirecipient forgetme${BLUE}${NC}"
docker compose exec -w "/srv/civi-sites/wmf" civicrm wmf-cv -vv api3 Omnirecipient.process_forgetme mail_provider=Silverpop
#Set on hold for emails we know not to be emailable due to bounce types from Silverpop
echo -e "${BLUE}Running ${GREEN}Omnirecipient onhold${BLUE}${NC}"
docker compose exec -w "/srv/civi-sites/wmf" civicrm wmf-cv -vv api3 Omnirecipient.process_onhold mail_provider=Silverpop rowCount=5000
#retrieve mailing data and store to tables (a combination of civicrm_campaign, civicrm_mailing and civicrm_mailing_stats)
echo -e "${BLUE}Running ${GREEN}Omnimailing load${BLUE}${NC}"
docker compose exec -w "/srv/civi-sites/wmf" civicrm wmf-cv -vv api3 Omnimailing.load mail_provider=Silverpop
#Get group member data from Silverpop in the 'no cid' group
echo -e "${BLUE}Running ${GREEN}Omnigroupmember load${BLUE}${NC}"
docker compose exec -w "/srv/civi-sites/wmf" civicrm wmf-cv -vv --in=json api3 Omnigroupmember.load
#match them with mailing data rows that are missing their contact_id because we sent a silverpop mailing before the contact made the round trip to CiviCRM and back out.
echo -e "${BLUE}Running ${GREEN}Omnigroupmember match${BLUE}${NC}"
docker compose exec -w "/srv/civi-sites/wmf" civicrm civicrm wmf-cv -vv api3 omnigroupmember.match group_id=310 limit=10000
