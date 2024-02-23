#!/bin/bash

# Adding the GitHub mirrors makes it easier to share links in PHPStorm via
# right-clicking a line in the code and selecting Open In... GitHub

# Note: we're using two indexed bash array to support MacOS bash v3.2 :(

paths=(
    "."
    "src/payments/extensions/DonationInterface"
    "src/donut/extensions/DonationInterface"
    "src/email-pref-ctr/extensions/DonationInterface"
    "src/smashpig/"
    "src/civi-sites/wmff"
    "src/tools"
    "src/django-banner-stats"
)

urls=(
    "https://github.com/wikimedia/wikimedia-fundraising-dev"
    "https://github.com/wikimedia/mediawiki-extensions-DonationInterface"
    "https://github.com/wikimedia/mediawiki-extensions-DonationInterface"
    "https://github.com/wikimedia/mediawiki-extensions-DonationInterface"
    "https://github.com/wikimedia/wikimedia-fundraising-SmashPig"
    "https://github.com/wikimedia/wikimedia-fundraising-crm"
    "https://github.com/wikimedia/wikimedia-fundraising-tools"
    "https://github.com/wikimedia/wikimedia-fundraising-tools-DjangoBannerStats"
)

# Loop through the directories
for i in "${!paths[@]}"; do
    path="${paths[$i]}"
    url="${urls[$i]}"

    # Check if the local directory exists
    if [ ! -d "$path" ]; then
        echo "Skipping $path as it does not exist."
        continue
    fi

    # Determine the .git directory or file
    git_dir=""
    if [ -d "$path/.git" ]; then
        git_dir="$path/.git"
    elif [ -f "$path/.git" ]; then
        git_dir=$(grep "gitdir" "$path/.git" | cut -d ' ' -f 2)
        if [[ -n $git_dir ]]; then
            git_dir="${path}/${git_dir}"
        else
            echo "Unable to determine git directory for submodule in $path."
            continue
        fi
    else
        echo "Skipping $path as it's not a valid Git repository."
        continue
    fi

    echo "Adding remote 'github' to $path with URL $url"
    # Navigate to the directory
    pushd "$path" > /dev/null || exit

    # Check if the remote 'github' already exists
    if git remote get-url github > /dev/null 2>&1; then
        echo "Remote 'github' already exists in $path. Skipping."
    else
        # Add the remote
        git remote add github "$url"
    fi

    # Navigate back to the top level directory
    popd > /dev/null
    echo
done
