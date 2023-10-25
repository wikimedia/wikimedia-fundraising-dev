#!/bin/bash

# Check for existence of a source dir and ask about removing and re-cloning
# $1 is the directory to check, $2 is a friendly name for the repository.
ask_reclone() {
    local reclone=true
    if [ -d $1 ]; then
        read -p "$1 exists. Remove and re-clone $2? [yN] " -r
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            read -p "Are you sure? This will delete $1, including local branches. [yN] " -r
            if ! [[ $REPLY =~ ^[Yy]$ ]]; then
                reclone=false
            fi
        else
            reclone=false
        fi
        echo >&2
    fi
    echo $reclone
}

# Copies file $1 to $1.bkup{n}, where n is the final number of the last backup + 1
backup() {
    i=0
    while [[ -e ${1}.bkup${i} || -L ${1}.bkup${i} ]]; do
        i=$((i+1))
    done
    cp $1 ${1}.bkup${i}
}

# Moves $1 to $2, backing up $2 if it's not identical to $1
backup_mv() {
    if [[ -e $2 || -L $2 ]] && ! cmp -s $1 $2; then
        echo "$2 contains customizations. Backing up."
        backup $2
    fi
    echo "Writing new $2"
    mv $1 $2
}

# Back up app-specific .idea and .git files
backup_config() {
      echo "Backing up app config $1/$2"
      mkdir -p .config-backup/"$1"
      mv "$3" .config-backup/"$1"/
}

# Restore app-specific .idea and .git files
restore_config() {
      echo "Restoring app config $1/$2"
      mkdir -p .config-backup/"$1"
      mv "$3" .config-backup/"$1"/
}

announce_install() {
  echo
  echo "The following app(s) are about to be installed:"
  for app_name in "$@"; do
    echo "  - $app_name"
  done
  echo
}

docker_compose_up() {
  local docker_compose_file="$1"
  local service_name="$2"

  docker compose -f "$docker_compose_file" up --force-recreate  -d "$service_name"
}