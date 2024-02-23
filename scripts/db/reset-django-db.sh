#!/bin/bash
# re-create the database
docker-compose exec -T database mysql -u root -e "DROP DATABASE dev_pgehres"
docker-compose exec -T database mysql -u root -e "CREATE DATABASE dev_pgehres"
# schema and populate country table
docker-compose exec -T database mysql -u root dev_pgehres < src/django-banner-stats/doc/001_create.sql
docker-compose exec -T database mysql -u root dev_pgehres < src/django-banner-stats/doc/002_populate_countries.sql
docker-compose exec -T database mysql -u root dev_pgehres < src/django-banner-stats/doc/003_populate_languages.sql