#!/bin/bash
# Create SQL script
cat <<EOF >/tmp/fundraising_ml_setup.sql
CREATE DATABASE IF NOT EXISTS fundraising_ml;
USE fundraising_ml;
EOF

cat src/fundraising-ml/sql/*sql >> /tmp/fundraising_ml_setup.sql

cat <<EOF >>/tmp/fundraising_ml_setup.sql
CREATE USER IF NOT EXISTS 'fundraising_ml'@'localhost' IDENTIFIED BY '$ML_DB_USER_PASSWORD';
CREATE USER IF NOT EXISTS 'fundraising_ml'@'%' IDENTIFIED BY '$ML_DB_USER_PASSWORD';
GRANT ALL PRIVILEGES ON fundraising_ml.* To 'fundraising_ml'@'localhost';
GRANT ALL PRIVILEGES ON fundraising_ml.* To 'fundraising_ml'@'%';
EOF

docker compose exec -T database mariadb </tmp/fundraising_ml_setup.sql

