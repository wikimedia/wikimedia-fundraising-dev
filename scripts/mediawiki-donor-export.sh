#!/bin/bash
docker compose exec -w "/srv/tools" tools env PYTHONPATH=/srv/tools python3 -m mediawiki_donor_export.export "$@"
