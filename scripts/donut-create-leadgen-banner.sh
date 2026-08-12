#!/bin/bash

docker compose exec -w "/var/www/html/w" donut \
	php maintenance/run.php /srv/config/exposed/donut/createLeadGenBanner.php
echo "Preview the leadgen banner at https://localhost:9010/wiki/Support_pages?banner=leadgen"
