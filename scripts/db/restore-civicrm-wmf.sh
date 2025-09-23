#!/bin/bash

CIVICRM_SERVICE_NAME="civicrm"
DATABASE_SERVICE_NAME="database"
CIVICRM_BACKUP_PATH="./.backup/sql/civicrm.sql"
TEST_BACKUP_PATH="./.backup/sql/civitest.sql"

if [ ! -f "$CIVICRM_BACKUP_PATH" ] || [ ! -f "$DRUPAL_BACKUP_PATH" ] || [ ! -f "$TEST_BACKUP_PATH" ]; then
    echo "CiviCRM-wmf standalone databases backup files not found. Check that you have the correct backup files in .backup/sql/"
    exit 1
fi

echo "**** Restoring CiviCRM standalone databases from backup"

echo "Restoring CiviCRM database..."
docker compose exec -T $CIVICRM_SERVICE_NAME mysql -uroot -h$DATABASE_SERVICE_NAME civicrm < $CIVICRM_BACKUP_PATH
echo "Restoring standalone Test database..."
docker compose exec -T $CIVICRM_SERVICE_NAME mysql -uroot -h$DATABASE_SERVICE_NAME civitest < $TEST_BACKUP_PATH
echo

echo "*** CiviCRM standalone databases restored."
