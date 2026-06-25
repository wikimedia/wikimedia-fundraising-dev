#!/bin/bash

# Migrate GitLab remotes from gitlab.wikimedia.org to gitlab-ssh.wikimedia.org.
#
# The production crew is moving GitLab behind the CDN, so SSH connections now
# go through a dedicated hostname. See https://phabricator.wikimedia.org/T425441
# and https://wikitech.wikimedia.org/wiki/GitLab/Migration
#
# Usage:
#   scripts/gitlab-migrate-remotes.sh [PATH]        # update remotes under PATH
#   scripts/gitlab-migrate-remotes.sh --dry-run [PATH]
#
# PATH defaults to the current directory. The script recursively finds every git
# repo beneath PATH and rewrites any remote pointing at the old hostname.

set -euo pipefail

OLD_HOST="gitlab.wikimedia.org"
NEW_HOST="gitlab-ssh.wikimedia.org"

dry_run=false
workdir="."

for arg in "$@"; do
    case "$arg" in
        --dry-run|-n) dry_run=true ;;
        -h|--help)
            grep '^#' "$0" | sed 's/^# \{0,1\}//'
            exit 0
            ;;
        *) workdir="$arg" ;;
    esac
done

if [ ! -d "$workdir" ]; then
    echo "Error: '$workdir' is not a directory." >&2
    exit 1
fi

echo "Scanning $workdir for git repos with a remote on $OLD_HOST..."

changed=0
# Find every .git directory (repos and submodules) under the work dir.
while IFS= read -r -d '' gitpath; do
    repo=$(dirname "$gitpath")

    # List remotes whose URL references the old host.
    while IFS= read -r line; do
        [ -z "$line" ] && continue
        name=$(echo "$line" | awk '{print $1}')
        url=$(git -C "$repo" remote get-url "$name")
        case "$url" in
            *"$OLD_HOST"*) ;;
            *) continue ;;
        esac

        new_url="${url//$OLD_HOST/$NEW_HOST}"
        echo "  $repo"
        echo "    $name: $url"
        echo "         -> $new_url"

        if [ "$dry_run" = false ]; then
            git -C "$repo" remote set-url "$name" "$new_url"
        fi
        changed=$((changed + 1))
    done < <(git -C "$repo" remote -v | grep "$OLD_HOST" | awk '{print $1}' | sort -u)
done < <(find "$workdir" -name .git -print0)

if [ "$changed" -eq 0 ]; then
    echo "No remotes on $OLD_HOST found."
elif [ "$dry_run" = true ]; then
    echo "Dry run: $changed remote(s) would be migrated."
else
    echo "Migrated $changed remote(s) to $NEW_HOST."
fi
