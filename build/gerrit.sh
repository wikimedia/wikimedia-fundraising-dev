if [ -z "${GIT_REVIEW_USER}" ]; then
    echo "**** Set up Gerrit user"
    read -rp "Gerrit user: " GIT_REVIEW_USER
    update_env "GIT_REVIEW_USER" "${GIT_REVIEW_USER}"
else
    echo "**** Gerrit user is currently set to: ${GIT_REVIEW_USER}"
    read -rp "Would you like to update it? [y/N]: "
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        read -rp "New git review user: " GIT_REVIEW_USER
        update_env "GIT_REVIEW_USER" "${GIT_REVIEW_USER}"
    fi
fi
