#!/usr/bin/env bash
set -Eeuo pipefail

ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../.." && pwd)"
STATE_DIR="/home/ubuntu/.local/state/chattered"
LOCK_FILE="$STATE_DIR/update.lock"
LOG_FILE="$STATE_DIR/update.log"

mkdir -p "$STATE_DIR"
exec >>"$LOG_FILE" 2>&1
exec 9>"$LOCK_FILE"
if ! flock -n 9; then
	printf '%s Another update check is already running.\n' "$(date --iso-8601=seconds)"
	exit 0
fi

COMPOSE=(docker compose --env-file "$ROOT_DIR/.env.dev" -f "$ROOT_DIR/docker/compose.dev.yml")

printf '%s Checking dev branches.\n' "$(date --iso-8601=seconds)"

if [[ ! -f "$ROOT_DIR/.env.dev" ]]; then
	printf '%s Missing %s; deployment skipped.\n' "$(date --iso-8601=seconds)" "$ROOT_DIR/.env.dev"
	exit 1
fi

if [[ "$(git -C "$ROOT_DIR" branch --show-current)" != "dev" ]]; then
	git -C "$ROOT_DIR" switch dev
fi

# Restore the submodule revisions recorded by the root before updating it.
git -C "$ROOT_DIR" submodule sync --recursive
git -C "$ROOT_DIR" submodule update --init --recursive
git -C "$ROOT_DIR" fetch --quiet origin dev
git -C "$ROOT_DIR" merge --ff-only origin/dev
git -C "$ROOT_DIR" submodule sync --recursive
git -C "$ROOT_DIR" submodule update --init --recursive

declare -A TARGETS=()
changed_server_or_worker=0

for module in server background mobile; do
	module_dir="$ROOT_DIR/$module"
	git -C "$module_dir" fetch --quiet origin dev
	target="$(git -C "$module_dir" rev-parse refs/remotes/origin/dev)"
	TARGETS["$module"]="$target"
	state_file="$STATE_DIR/$module.sha"
	previous=""
	if [[ -f "$state_file" ]]; then
		previous="$(cat "$state_file")"
	fi

	if [[ "$target" != "$previous" ]]; then
		printf '%s %s dev changed: %s\n' "$(date --iso-8601=seconds)" "$module" "$target"
		git -C "$module_dir" checkout --detach "$target"
		if [[ "$module" == "server" || "$module" == "background" ]]; then
			changed_server_or_worker=1
		fi
	fi
done

if (( changed_server_or_worker )); then
	# Complete both builds before asking Compose to replace either running service.
	"${COMPOSE[@]}" build server background
	"${COMPOSE[@]}" up -d --no-deps server background
	"${COMPOSE[@]}" ps server background
fi

for module in server background mobile; do
	printf '%s\n' "${TARGETS[$module]}" >"$STATE_DIR/$module.sha.tmp"
	mv "$STATE_DIR/$module.sha.tmp" "$STATE_DIR/$module.sha"
done

printf '%s Dev branch check completed.\n' "$(date --iso-8601=seconds)"
