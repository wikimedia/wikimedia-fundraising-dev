#!/bin/bash

docker compose exec database mariadb -u root $@
