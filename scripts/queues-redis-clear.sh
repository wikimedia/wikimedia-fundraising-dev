#!/bin/bash
# Clears contents of all Redis queues, preserving sequence number

# Get the current sequence number (removing quotes and any trailing newline characters)
echo "GET sequence_contribution-tracking"
current_seq=$(./queues-redis-cli.sh GET sequence_contribution-tracking | tr -d '"\n\r')
echo ${current_seq}

# Clear everything
echo "FLUSHALL"
./queues-redis-cli.sh FLUSHALL

if [ "${current_seq}" != "(nil)" ]; then
  # Restore sequence number
  echo "SET sequence_contribution-tracking ${current_seq}"
  ./queues-redis-cli.sh SET sequence_contribution-tracking "${current_seq}"
fi
