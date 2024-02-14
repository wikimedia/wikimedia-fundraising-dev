#!/bin/bash

CIVICRM_SERVICE_NAME="civicrm"
DATABASE_SERVICE_NAME="database"
CIVICRM_BACKUP_PATH="./.backup/sql/core_civicrm_backup.sql"
DRUPAL_BACKUP_PATH="./.backup/sql/core_drupal_backup.sql"
TEST_BACKUP_PATH="./.backup/sql/core_test_backup.sql"

if [ ! -f "$CIVICRM_BACKUP_PATH" ] || [ ! -f "$DRUPAL_BACKUP_PATH" ] || [ ! -f "$TEST_BACKUP_PATH" ]; then
    echo "CiviCRM Core databases backup files not found. Check that you have the correct backup files in .backup/sql/"
    exit 1
fi

echo "**** Restoring CiviCRM Core databases from backup"

echo "Restoring CiviCRM database..."
docker compose exec -T $CIVICRM_SERVICE_NAME mysql -uroot -h$DATABASE_SERVICE_NAME dmastercivicrm < $CIVICRM_BACKUP_PATH

echo "Restoring Drupal database..."
docker compose exec -T $CIVICRM_SERVICE_NAME mysql -uroot -h$DATABASE_SERVICE_NAME dmastercms < $DRUPAL_BACKUP_PATH

echo "Restoring Core Test database..."
docker compose exec -T $CIVICRM_SERVICE_NAME mysql -uroot -h$DATABASE_SERVICE_NAME dmastertest < $TEST_BACKUP_PATH
echo

echo "*** CiviCRM Core databases restored."
