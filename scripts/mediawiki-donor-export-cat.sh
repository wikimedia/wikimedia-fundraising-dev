#!/bin/bash
# Display all MediaWiki donor export CSVs from the tools container.
# Run mediawiki-donor-export.sh first to generate the exports.
docker compose exec -T tools sh -c 'for f in /tmp/mediawiki_donor_export/*.csv; do echo "=== $f ==="; cat "$f"; echo; done'
