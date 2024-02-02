#!/bin/sh
if [ -e "$BRIANTAKITAME_PORT" ]; then
	error() {
		echo "$@" >> /dev/stderr
	}
	error 'environment variables not loaded'
	error 'run the following command if you are running on bash'
	# shellcheck disable=SC2016
	error 'eval "$(direnv export bash)"'
	exit 1
fi
