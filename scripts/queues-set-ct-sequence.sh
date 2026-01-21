#!/bin/bash

# Get the full path to the directory containing this script
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

read -r -p "What number would you like to set the contribution-tracking sequence to? " sequence

# Check if the input is not empty and is numeric
if [[ ! -z "$sequence" ]] && [[ "$sequence" =~ ^[0-9]+$ ]]; then
  "${script_dir}/queues-cli.sh" SET sequence_contribution-tracking "$sequence"
  echo "contribution-tracking sequence set to: $sequence."
else
  echo "Error: Please enter a non-empty numeric value."
fi
