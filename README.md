# Chattered

The Chattered root repository brings together the mobile app, API, and background worker as Git submodules. The root repository records the commit used by each module.

## Directories

- `mobile/`: Expo and React Native mobile app (Git submodule).
- `server/`: Gin-based Go API (Git submodule).
- `background/`: Asynq-based Go background worker (Git submodule).
- `docker/`: PostgreSQL, Redis, API, background worker, Caddy reverse proxy, and ACME certificate renewal services in `compose.dev.yml`.

Each submodule keeps its own Git history and `dev` branch. These repositories are private, so the GitHub account used to clone must have access to the root repository and all three submodule repositories.

## Clone

Clone the repository with all submodules:

```sh
git clone --recurse-submodules git@github.com:cakmakfatih/chattered.git
```

If the repository was cloned without its submodules, initialize them with:

```sh
git submodule update --init --recursive
```

## Development environment

1. Copy the root `.env.example` to `.env.dev` and replace the password placeholders and Clerk secret key.
2. Start the services with `docker compose -f docker/compose.dev.yml up --build`. The API and background worker use the root `.env.dev`; PostgreSQL, Redis, and the API are not published on host ports. Caddy is the only service published, on TCP port `443`.
3. Copy `mobile/.env.example` to `mobile/.env.dev`, then set the Clerk publishable key and API URL. Enable Native API in the Clerk Dashboard for the mobile Clerk flow.
4. To run the API with hot reload outside Compose, copy `server/.env.example` to `server/.env.dev`, set its values, and run `go tool air` from `server/`.
5. To start the mobile app, run `npm install` and `npx expo start` from `mobile/`.

When running the API directly on your development computer, use its local network address in the mobile app instead of `localhost`.

For a public development server without a domain, Caddy terminates HTTPS for the machine's public IPv4 address. The ACME sidecar obtains and renews a short-lived IP certificate using the TLS-ALPN challenge on port `443`; no public IP is hard-coded in the Compose files. Allow inbound TCP `443` in the host firewall/security rules.

### Automatic dev deployment

The deployment host can run `docker/deploy/update-dev-submodules.sh` once per minute from the `ubuntu` user's crontab. It fetches the `dev` branch of each submodule, checks out the newest revisions locally, and rebuilds and recreates only the `server` and `background` services when either of those revisions changes. A mobile-only update does not rebuild any Docker service. Both Go service images are built before Compose replaces their containers, so the running API remains available during the build; Compose then recreates the updated containers. The deployment checkout follows submodule `dev` tips locally and does not push submodule pointer commits to the root repository. The script only checks out the root `dev` branch and does not change `main`.

The internal Background health endpoint is available as `GET /ping` through HTTPS on the API proxy and returns plain-text `pong`. The worker's port is not published on the host.
