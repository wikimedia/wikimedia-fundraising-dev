if [ -z "${COMPOSE_PROJECT_NAME}" ]; then
    echo
    echo "**** (Optional) Set up Docker Compose project name:"
    read -rp "Defaults to 'fundraising-dev'. Would you like to update it? [y/N]: "
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        read -rp "Enter Custom Docker Compose project name: " COMPOSE_PROJECT_NAME
        update_env "COMPOSE_PROJECT_NAME" "${COMPOSE_PROJECT_NAME}"
    else
      update_env "COMPOSE_PROJECT_NAME" "fundraising-dev"
    fi
fi
