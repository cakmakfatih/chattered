#!/bin/sh
set -eu

chmod 0440 /certs/privkey.pem /certs/fullchain.pem
chgrp 1000 /certs/privkey.pem /certs/fullchain.pem

curl --fail --silent --show-error \
	--request POST \
	--header "Content-Type: text/caddyfile" \
	--data-binary @/etc/caddy/Caddyfile \
	http://caddy:2019/load
