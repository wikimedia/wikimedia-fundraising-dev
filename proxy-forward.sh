#!/bin/bash

# Script to set up fundraising development environment
source .env

if [ -z "$PROXY_FORWARD_ID" ] || \
	[ -z "$PAYMENTS_HTTP_PORT" ] || \
	[ -z "$SMASHPIG_PORT" ]; then
	echo "Please run setup.sh to choose a proxy forwarding ID, a payments HTTP port"\
		"and a SmashPig port."
	exit 1
fi

# With the --autossh flag, we try to run using autossh
if ! [ -z $1 ]; then
	if [ $1 = "--autossh" ]; then
		# Error out if autossh is not available
		if ! command -v autossh &> /dev/null; then
			echo "autossh not found."
			exit 1
		fi
		use_autossh=true
	else
		echo "Unrecognized option: $1"
		exit 1
	fi
else
	use_autossh=false
fi

payments_remote_port=$((8000 + PROXY_FORWARD_ID))
ipn_remote_port=$((8100 + PROXY_FORWARD_ID))

ssh_args="
 -N -o ServerAliveInterval=30 -o ServerAliveCountMax=3 -o ExitOnForwardFailure=yes
 -R $payments_remote_port:localhost:$PAYMENTS_HTTP_PORT\
 -R $ipn_remote_port:localhost:$SMASHPIG_PORT\
 payments-trixie.fr-tech-dev.eqiad1.wikimedia.cloud
"

output_msg="
https://paymentstest$PROXY_FORWARD_ID.wmcloud.org should forward\
 to http://localhost:$PAYMENTS_HTTP_PORT\n\
https://paymentsipntest$PROXY_FORWARD_ID.wmcloud.org should forward
 to http://localhost:$SMASHPIG_PORT
"

if [ $use_autossh = true ]; then
	cmd_to_run="autossh -M 0 $ssh_args"
	echo -e $output_msg
	echo $cmd_to_run
	eval $cmd_to_run
else
	cmd_to_run="ssh -f $ssh_args"
	echo $cmd_to_run
	eval $cmd_to_run && echo -e $output_msg
fi
