#!/bin/bash
docker compose exec -w "/srv/tools" tools /bin/sh -c "env PYTHONPATH=/srv/tools  python3 /srv/tools/silverpop_export/export.py"