#!/bin/bash

CIVICRM_SERVICE_NAME="civicrm"
DATABASE_SERVICE_NAME="database"
CIVICRM_BACKUP_PATH="./.backup/sql/wmff_civicrm_backup.sql"
DRUPAL_BACKUP_PATH="./.backup/sql/wmff_drupal_backup.sql"
WMFF_TEST_BACKUP_PATH="./.backup/sql/wmff_test_backup.sql"

if [ ! -f "$CIVICRM_BACKUP_PATH" ] || [ ! -f "$DRUPAL_BACKUP_PATH" ] || [ ! -f "$WMFF_TEST_BACKUP_PATH" ]; then
    echo "CiviCRM WMFF databases backup files not found. Check that you have the correct backup files in .backup/sql/"
    exit 1
fi

echo "**** Restoring CiviCRM WMFF databases from backup"

echo "Restoring CiviCRM database..."
docker compose exec -T $CIVICRM_SERVICE_NAME mysql -uroot -h$DATABASE_SERVICE_NAME civicrm < $CIVICRM_BACKUP_PATH

echo "Restoring Drupal database..."
docker compose exec -T $CIVICRM_SERVICE_NAME mysql -uroot -h$DATABASE_SERVICE_NAME drupal < $DRUPAL_BACKUP_PATH

echo "Restoring WMFF Test database..."
docker compose exec -T $CIVICRM_SERVICE_NAME mysql -uroot -h$DATABASE_SERVICE_NAME wmff_test < $WMFF_TEST_BACKUP_PATH
echo

echo "*** CiviCRM WMFF databases restored."
