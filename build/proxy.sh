if [ -z "${PROXY_FORWARD_ID}" ]; then
    echo
    echo "**** Select paymentstest{$}.wmcloud.org testing web address (you can edit .env to change it later)"
    while ! [[ $PROXY_FORWARD_ID =~ ^[1-6]$ ]]; do
      read -p "Which paymentstest{$}.wmcloud.org numerical URL identifier do you want to use (1-6)?: " PROXY_FORWARD_ID
    done
    update_env "PROXY_FORWARD_ID" "${PROXY_FORWARD_ID}"
fi
