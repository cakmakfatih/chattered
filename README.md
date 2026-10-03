# Chattered

The Chattered root repository combines three Git submodules and owns their shared Docker workflows:

- `mobile/`: Expo and React Native mobile app.
- `server/`: Gin-based Go API and Atlas migrations.
- `background/`: Asynq-based Go background worker.
- `docker/`: remote development and local workstation Compose files.

Each submodule keeps its own Git history. The GitHub account used to clone this private project must have access to the root repository and all three component repositories.

## Clone

Clone the repository with all submodules:

```sh
git clone --recurse-submodules git@github.com:cakmakfatih/chattered.git
```

If the repository was cloned without its submodules, initialize them with:

```sh
git submodule update --init --recursive
```

## Development server

The remote development stack runs PostgreSQL, Redis, Server, Background, Caddy, and the ACME certificate sidecar in Compose. PostgreSQL, Redis, Server, and Background stay on the Compose network; only Caddy publishes TCP port `443`. Caddy serves the API over HTTPS and routes `GET /ping` to Background.

Required environment files:

1. Copy root `.env.example` to `.env.dev`. Replace the PostgreSQL and Redis passwords and set a real Clerk secret key.
2. Copy `mobile/.env.example` to `mobile/.env.dev`. Set the Clerk publishable key and the development server's HTTPS API URL. Enable Native API in the Clerk Dashboard.

Start or rebuild the remote development stack from the repository root:

```sh
docker compose -f docker/compose.dev.yml up --build
```

After `mobile/.env.dev` points to the remote development API, install dependencies if needed and start Mobile from `mobile/`:

```sh
npm ci
npm run start
```

For a public development server without a domain, the ACME sidecar discovers the host's public IPv4 address and obtains a short-lived Let's Encrypt IP certificate through the TLS-ALPN challenge on port `443`. Allow inbound TCP `443` in the host firewall and cloud security rules.

### Automatic development deployment

The deployment host can run `docker/deploy/update-dev-submodules.sh` once per minute from the `ubuntu` user's crontab. The script fast-forwards the root `dev` branch, follows each submodule's `dev` tip locally, and rebuilds and recreates Server and Background when either changes. A mobile-only update does not rebuild Docker services. It does not commit submodule pointer changes or modify `main`.

## Local workstation development

Local development runs PostgreSQL, Redis, Background, and a one-shot Atlas migrator in Compose. Server runs on the host with Air for hot reload, and Mobile runs on the host with Expo. Local Compose does not include Server, Caddy, or ACME.

Prepare these ignored environment files:

1. Copy root `.env.example` to `.env.local`, retain its existing keys, and set the local Compose values to `POSTGRES_USER=chattered`, `POSTGRES_PASSWORD=chatteredlocal`, `POSTGRES_DB=chattered`, `REDIS_PASSWORD=chatteredlocal`, and `REDIS_ADDR=redis:6379`. Extra keys from the shared format are harmless; local Compose uses only the values its services need. Compose passes the root file to Background, so a Background-specific environment file is not required for this workflow.
2. Copy `server/.env.example` to `server/.env.local`. Replace the Clerk secret and set `DATABASE_URL=postgres://chattered:chatteredlocal@127.0.0.1:5432/chattered?sslmode=disable`, `HOST=0.0.0.0`, `PORT=8080`, and `GIN_MODE=debug`.
3. Copy `mobile/.env.example` to `mobile/.env.local`. Set the Clerk publishable key and set `EXPO_PUBLIC_API_URL` to `http://<LAN_IP>:8080`, using the development computer's LAN address. Keep `mobile/.env.dev` for the remote development server workflow.

Launch the local workflow in three terminals.

1. Start infrastructure, apply pending migrations, and run Background from the repository root:

   ```sh
   docker compose --env-file .env.local -f docker/compose.local.yml up --build
   ```

   PostgreSQL is bound only to host loopback on port `5432`. Redis remains internal to Compose. Atlas waits for PostgreSQL, applies `server/migrations`, and must complete successfully before Background starts. The local PostgreSQL and Redis data volumes are separate from the remote development volumes.

2. Start Server with hot reload from `server/`:

   ```sh
   go tool air -c .air.local.toml
   ```

   Server listens on `0.0.0.0:8080`. Atlas already applied the migrations, so Air only starts and reloads the API.

3. Install Mobile dependencies and start Expo in LAN mode from `mobile/`:

   ```sh
   npm ci
   npm run start:local
   ```

`localhost` on a physical phone refers to the phone, not the development computer. Keep `127.0.0.1` in Server's database URL because Server runs on the computer, but use the computer's LAN IP in Mobile's API URL so the phone can reach port `8080`.

If you change the root PostgreSQL username, password, database, or port mapping, update `server/.env.local` to match. Keep the Redis address and password in root `.env.local`; Compose passes them to Background and uses the password for Redis. Background's own `.env.local` is optional and only needed when running that component outside the root Compose workflow. The sample credentials are for local development only.

## Production

Production deployment is not configured yet and will be defined separately.
