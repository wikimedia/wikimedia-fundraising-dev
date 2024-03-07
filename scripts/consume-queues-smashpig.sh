#!/bin/bash
BLUE='\033[1;34m'
GREEN='\033[1;32m'
NC='\033[0m' # No Color

echo -e "${BLUE}Running ${GREEN}pending${BLUE} queue consumer${NC}"
docker compose exec smashpig php /srv/smashpig/Maintenance/ConsumePendingQueue.php

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
