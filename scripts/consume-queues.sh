#!/bin/bash

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "${script_dir}/consume-queues-smashpig.sh"
source "${script_dir}/consume-queues-civicrm.sh"
