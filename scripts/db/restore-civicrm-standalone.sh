#!/bin/bash

CIVICRM_SERVICE_NAME="civicrm"
DATABASE_SERVICE_NAME="database"
CIVICRM_BACKUP_PATH="./.backup/sql/standalone_civicrm_backup.sql"
TEST_BACKUP_PATH="./.backup/sql/standalone_test_backup.sql"

if [ ! -f "$CIVICRM_BACKUP_PATH" ] || [ ! -f "$DRUPAL_BACKUP_PATH" ] || [ ! -f "$TEST_BACKUP_PATH" ]; then
    echo "CiviCRM standalone databases backup files not found. Check that you have the correct backup files in .backup/sql/"
    exit 1
fi

echo "**** Restoring CiviCRM standalone databases from backup"

echo "Restoring CiviCRM database..."
docker compose exec -T $CIVICRM_SERVICE_NAME mysql -uroot -h$DATABASE_SERVICE_NAME standalonedev_civi < $CIVICRM_BACKUP_PATH
echo "Restoring standalone Test database..."
docker compose exec -T $CIVICRM_SERVICE_NAME mysql -uroot -h$DATABASE_SERVICE_NAME standalonedev_test < $TEST_BACKUP_PATH
echo

echo "*** CiviCRM standalone databases restored."
