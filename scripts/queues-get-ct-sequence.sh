#!/bin/bash

# Get the full path to the directory containing this script
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Fetch the contribution-tracking sequence
sequence=$( "${script_dir}/queues-redis-cli.sh" GET sequence_contribution-tracking )

if [ $? -eq 0 ]; then
    if [ -n "$sequence" ]; then
        echo "Current contribution-tracking sequence: $sequence"
    else
        echo "contribution-tracking sequence is not set or empty."
    fi
else
    echo "Failed to get the contribution-tracking sequence."
fi
