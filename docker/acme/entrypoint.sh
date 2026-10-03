#!/bin/sh
set -eu

public_ip="$(curl -4fsS https://api.ipify.org)"
case "$public_ip" in
	""|*[!0-9.]* )
		echo "Could not determine a public IPv4 address for the TLS certificate." >&2
		exit 1
		;;
esac

acme.sh --set-default-ca --server letsencrypt
acme.sh --issue \
	--server letsencrypt \
	--certificate-profile shortlived \
	--alpn \
	--tlsport 8443 \
	--keylength ec-256 \
	--days 3 \
	-d "$public_ip"

acme.sh --install-cert \
	-d "$public_ip" \
	--ecc \
	--key-file /certs/privkey.pem \
	--fullchain-file /certs/fullchain.pem \
	--reloadcmd /scripts/reload-caddy.sh

while :; do
	sleep 14400
	acme.sh --cron
done
