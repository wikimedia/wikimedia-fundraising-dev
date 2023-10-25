#!/bin/bash

docker compose exec -w "/var/www/html" payments \
	/bin/bash
