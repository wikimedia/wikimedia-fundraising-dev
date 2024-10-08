#!/bin/bash

if [ -z "$1" ]; then
  echo "Usage: $0 GERRIT_PATCH_ID"
  exit 1
fi

PATCH_ID=$1
LAST_TWO_DIGITS=${PATCH_ID: -2}
echo "Using Patch ID: $PATCH_ID"

# Fetch latest patchset revision number from Gerrit API (this should be easier!)
LATEST_REVISION=$(curl -s "https://gerrit.wikimedia.org/r/changes/$PATCH_ID/detail" | grep -oE '"_revision_number":[^}]*' | sed 's/"_revision_number"://g' | sort -n | tail -n 1)
echo "*** Patch Set latest revision: $LATEST_REVISION"

# See if we need to backup the original version of smashpig and checkout the gerrit remote
# Note: we don't need to do this for follow-on patch testing. See https://gerrit.wikimedia.org/r/c/wikimedia/fundraising/dev/+/1046738/comments/678f5db0_fe4c7485
if ! docker compose exec civicrm bash -c '[ -d "/srv/civi-sites/wmff/vendor/wikimedia/smash-pig/.git" ]'; then
  echo "*** Backing up existing SmashPig library..."

  # Check if the backup directory exists and remove it
  docker compose exec civicrm bash -c 'if [ -d "/srv/civi-sites/wmff/vendor/wikimedia/smash-pig-backup" ]; then rm -rf /srv/civi-sites/wmff/vendor/wikimedia/smash-pig-backup; fi'

  # Backup smash-pig directory
  docker compose exec -w "/srv/civi-sites/wmff/" civicrm  mv vendor/wikimedia/smash-pig/ vendor/wikimedia/smash-pig-backup

  # Clone repo and checkout patch set passed as arg to /srv/civi-sites/wmff/vendor/wikimedia/smash-pig
  echo "*** Cloning the SmashPig repository to vendor/wikimedia/smash-pig"
  docker compose exec civicrm git clone "https://gerrit.wikimedia.org/r/wikimedia/fundraising/SmashPig" /srv/civi-sites/wmff/vendor/wikimedia/smash-pig
fi

# Checkout the latest patchset
echo "*** Fetching patchset/revision $PATCH_ID/$LATEST_REVISION"

docker compose exec -w "/srv/civi-sites/wmff/vendor/wikimedia/smash-pig" civicrm git fetch https://gerrit.wikimedia.org/r/wikimedia/fundraising/SmashPig refs/changes/$LAST_TWO_DIGITS/$PATCH_ID/$LATEST_REVISION && \
docker compose exec -w "/srv/civi-sites/wmff/vendor/wikimedia/smash-pig" civicrm git checkout -b change-$PATCH_ID FETCH_HEAD

if [ $? -eq 0 ]; then
  echo "SmashPig patch $PATCH_ID checked out to vendor/wikimedia/smash-pig"
else
  echo "Failed to apply the patch set."
  exit 1
fi

# Run composer install to refresh autoloaders
echo "*** Run composer install"
docker compose exec -w "/srv/civi-sites/wmff/" civicrm composer install

echo "*** SmashPig patch $PATCH_ID checkout complete and composer install finished. Done!"

