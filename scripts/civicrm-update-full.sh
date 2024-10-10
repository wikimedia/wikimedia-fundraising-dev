#!/bin/bash

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "*** CiviCRM Full Update starting:"
source "${script_dir}/civicrm-update-database.sh"
source "${script_dir}/civicrm-update-extensions.sh"
source "${script_dir}/civicrm-update-managed-entities.sh"
source "${script_dir}/civicrm-update-custom-fields.sh"
echo "*** CiviCRM Full Update Done!"
