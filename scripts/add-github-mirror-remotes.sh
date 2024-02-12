#!/bin/bash

# Adding the github mirrors makes it easier to share links in PHPStorm via
# right clicking a line in the code and selecting Open In... github

declare -A repos=(
    ["."]="https://github.com/wikimedia/wikimedia-fundraising-dev"
    ["src/payments/extensions/DonationInterface"]="https://github.com/wikimedia/mediawiki-extensions-DonationInterface"
    ["src/donut/extensions/DonationInterface"]="https://github.com/wikimedia/mediawiki-extensions-DonationInterface"
    ["src/email-pref-ctr/extensions/DonationInterface"]="https://github.com/wikimedia/mediawiki-extensions-DonationInterface"
    ["src/smashpig/"]="https://github.com/wikimedia/wikimedia-fundraising-SmashPig"
    ["src/civi-sites/wmff"]="https://github.com/wikimedia/wikimedia-fundraising-crm"
    ["src/tools"]="https://github.com/wikimedia/wikimedia-fundraising-tools"
)

# Loop through local directory => repo
for path in "${!repos[@]}"; do
    url="${repos[$path]}"

    # Check if the local directory exists
    if [ ! -d "$path" ]; then
        echo "Skipping $path as it does not exist."
        continue
    fi

    # Check if .git is a directory (regular repo) or a file (submodule)
    if [ -d "$path/.git" ]; then
        git_dir="$path/.git"
    elif [ -f "$path/.git" ]; then
        # For submodules, .git is a file. Extract the git directory path.
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

    # Check if the remote already exists
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
