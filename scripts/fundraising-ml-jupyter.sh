#!/bin/sh
docker compose exec -w /srv/fundraising-ml fundraising-ml /srv/ml-venv/bin/jupyter-notebook --ip=0.0.0.0
