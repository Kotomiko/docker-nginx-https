#!/bin/sh

_nginx_want_help() {
	local arg
	for arg; do
		case "$arg" in
			-'?'|-h|-v|-V|-t)
				return 0
				;;
		esac
	done
	return 1
}

if [ "$1" = 'nginx' ] && ! _nginx_want_help "$@"; then
	if [ "$(id -u)" = '0' ]; then
		exec su-exec nginx "$@" -g "daemon off;"
	fi
fi

exec "$@"