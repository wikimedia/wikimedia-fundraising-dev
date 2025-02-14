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
if ! docker compose exec payments bash -c '[ -d "/var/www/html/vendor/wikimedia/smash-pig/.git" ]'; then
  echo "*** Backing up existing SmashPig library..."

  # Check if the backup directory exists and remove it
  docker compose exec payments bash -c 'if [ -d "/var/www/html/vendor/wikimedia/smash-pig-backup" ]; then rm -rf /var/www/html/vendor/wikimedia/smash-pig-backup; fi'

  # Backup smash-pig directory
  docker compose exec -w "/var/www/html/" payments  mv vendor/wikimedia/smash-pig/ vendor/wikimedia/smash-pig-backup

  # Clone repo and checkout patch set passed as arg to /var/www/html/vendor/wikimedia/smash-pig
  echo "*** Cloning the SmashPig repository to vendor/wikimedia/smash-pig"
  docker compose exec payments git clone "https://gerrit.wikimedia.org/r/wikimedia/fundraising/SmashPig" /var/www/html/vendor/wikimedia/smash-pig
fi
docker compose exec -w "/var/www/html/vendor/wikimedia/smash-pig" payments git checkout master

echo "*** Fetching patchset/revision $PATCH_ID/$LATEST_REVISION"
# Delete branch if it already exists to get latest changes
docker compose exec -w "/var/www/html/vendor/wikimedia/smash-pig" payments git branch -D change-$PATCH_ID &>/dev/null || :
# Checkout the latest patchset
docker compose exec -w "/var/www/html/vendor/wikimedia/smash-pig" payments git fetch https://gerrit.wikimedia.org/r/wikimedia/fundraising/SmashPig refs/changes/$LAST_TWO_DIGITS/$PATCH_ID/$LATEST_REVISION && \
docker compose exec -w "/var/www/html/vendor/wikimedia/smash-pig" payments git checkout -b change-$PATCH_ID FETCH_HEAD

if [ $? -eq 0 ]; then
  echo "SmashPig patch $PATCH_ID checked out to vendor/wikimedia/smash-pig"
else
  echo "Failed to apply the patch set."
  exit 1
fi

# Refresh autoloaders
echo "*** Run composer dump-autoload"
docker compose exec -w "/var/www/html/" payments composer dump-autoload

echo "*** SmashPig patch $PATCH_ID checkout complete and composer install finished. Done!"
docker compose exec -w "/var/www/html/vendor/wikimedia/smash-pig" payments git log -1
