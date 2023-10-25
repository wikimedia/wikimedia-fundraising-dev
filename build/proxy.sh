if [ -z "${PROXY_FORWARD_ID}" ]; then
    echo
    echo "**** Select paymentstest{$}.wmcloud.org testing web address"
    read -p "Which paymentstest{$}.wmcloud.org numerical URL identifier do you want to use (1-6)?: " PROXY_FORWARD_ID
    update_env "PROXY_FORWARD_ID" "${PROXY_FORWARD_ID}"
else
    echo
    echo "**** Test address paymentstest$PROXY_FORWARD_ID.wmcloud.org is currently set"
    read -rp "Would you like to update it? [y/N]: "
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        read -rp "New paymentstest{$}.wmcloud.org numerical ID: " PROXY_FORWARD_ID
        update_env "PROXY_FORWARD_ID" "${PROXY_FORWARD_ID}"
    fi
fi
