#!/bin/bash
# Monitor queues in a pretty format, including pretty-printed json messages

# Turn off globbing so the "*" in "keys *" doesn't do funny things
set -f

format() {
	local line
	while IFS= read -r line; do

		# extract the arguments actually sent to Redis (removing timestamp and server)
		args=$( echo $line | sed -n 's/^.*\] \(".*"\)$/\1/p' )

		# if we couldn't extract the arguments, just echo out the line
		if [ -z "${args}" ]; then
			echo $line
			continue
		fi

		# check the command sent to Redis
		cmd=$( echo $args | awk '{printf $1}' )

		# handle RPUSH separately to pretty-print the queue message
		if [[ $cmd =~ 'RPUSH' ]]; then
			# output the command and queue name without the quotes
			cmd_and_queue=$( echo $line | awk '{print $4, $5}' | sed 's/"//g' )
			echo "$cmd_and_queue"

			# get the message content and unescape
			msg_content=$( \
				echo $line \
				| sed -n 's/^.*" "\([{}].*\)"/\1/p' \
				| sed 's/\\\(.\)/\1/g' )

			# pretty-print json, redirecting stderr to not clutter output with parsing errors
			msg_pretty=$( echo $msg_content | python3 -m json.tool --sort-keys --no-ensure-ascii 2>/dev/null )

			# if we didn't get valid json, just output the raw message, otherwise output
			# the pretty-printed json
			if [ -z "${msg_pretty}" ]; then
				echo "(Invalid JSON) $msg_content"
			else
				echo "$msg_pretty"
			fi
		else
			# for commands other than RPUSH, remove the quotes and output whatever was
			# sent to Redis
			cleaned_args=$( echo $args | sed 's/"//g' )
			echo "${cleaned_args}"
		fi
	done
}

tempfile=$(mktemp)
trap 'rm -f $tempfile' EXIT

# Run both redis queue monitor commands in the background and push their outputs to the tempfile
docker compose exec -T queues redis-cli MONITOR >> $tempfile &
docker compose exec -T donorprefsqueues redis-cli MONITOR >> $tempfile &

# tail -f the tempfile and pipe its contents our format func
tail -f $tempfile | format