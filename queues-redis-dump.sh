#!/bin/bash
# Outputs the contents of all queue messages

# get an array of Redis keys containing values
keys=($(./queues-redis-cli.sh keys "*" | grep -o '\".*\"' | tr -d '"' | tr '\n' ' '))

for key in ${keys[@]}
do
	echo "----- ${key} -----"
	echo

	if [[ $key =~ 'sequence' ]]; then
		# sequence is of string type, so we use GET
		./queues-redis-cli.sh GET $key
		echo
	else
		# We need an array of messages to loop over.
		# It seems just swapping out spaces seems is the easiest cross-shell to way to
		# put the messaages into an array.
		all_msgs_x=($(./queues-redis-cli.sh LRANGE $key 0 -1 | sed 's/ /---NOT-A-SPACE---/g'))

		for msg_x in ${all_msgs_x[@]}
		do
			# put the spaces back in
			msg=$( echo $msg_x | sed 's/---NOT-A-SPACE---/ /g' )

			# get the message index number and output it
			idx=$( echo $msg | sed -n 's/^\([0-9]*\)[^0-9] .*/\1/p' )
			echo "[$idx]"

			# get the message content and unescape
			msg_content=$( \
				echo $msg \
				| sed -n 's/^[0-9]*[^0-9] "\(.*\)"/\1/p' \
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

			echo

		done
	fi
done
