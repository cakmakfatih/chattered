FROM caddy:2.11.7-builder-alpine AS builder

RUN xcaddy build v2.11.7 \
    --with github.com/mholt/caddy-l4@v0.1.1 \
    --output /usr/bin/caddy

FROM caddy:2.11.7-alpine

COPY --from=builder /usr/bin/caddy /usr/bin/caddy

RUN mkdir -p /certs /data /config \
    && chown -R 1000:1000 /certs /data /config

USER 1000:1000
