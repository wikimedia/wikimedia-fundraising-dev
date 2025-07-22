#!/bin/bash

civisite=$1; shift

if [[ -z $civisite ]]; then
	echo "First argument must be the name of the civi site to run tests on (such as wmf)"
	exit 1
fi

docker compose exec -w "/srv/civi-sites/$civisite" \
	civicrm vendor/phpunit/phpunit/phpunit $@
