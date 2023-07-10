#!/bin/bash

docker-compose exec -w "/srv/smashpig" smashpig ./vendor/bin/phpunit --ignore-dependencies $@
