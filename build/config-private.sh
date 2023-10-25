# config-private setup
CONFIG_PRIVATE_DIR="./config-private"

if [[ ! -e ${CONFIG_PRIVATE_DIR:?} ]]; then
  echo
  echo "**** Set up config-private"
  read -rp "Would you like to clone config-private? (needed for some apps to run!) [y/N]: "
  if [[ $REPLY =~ ^[Yy]$ ]]; then

    clone_private=$(ask_reclone "config-private" "config-private repo")
    if [ $clone_private = true ]; then
      rm -rf ${CONFIG_PRIVATE_DIR:?}
      echo
      echo "See https://phabricator.wikimedia.org/T266093 for remote for config-private repo."
      read -p "Please enter remote for config-private repo (or leave blank to create an empty stub directory): " private_remote

      if [[ -z $private_remote ]]; then
        echo "**** Creating empty stub director config-private"
        mkdir ${CONFIG_PRIVATE_DIR:?}
      else
        echo "**** Cloning config-private repo in config-private"
        git clone $private_remote ${CONFIG_PRIVATE_DIR:?}
        echo
        echo "**** Cloned config-private repo!!!"
      fi

      echo
    fi
  fi
fi