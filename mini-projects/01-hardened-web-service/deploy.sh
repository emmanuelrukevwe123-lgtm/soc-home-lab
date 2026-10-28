#!/usr/bin/env bash
# Deploy the hardened web service. Safe to run again (idempotent).
set -euo pipefail                      # stop on errors, unset variables and failed pipes

cd "$(dirname "$0")"                   # run from this folder wherever it's called from
[ -f .env ] && set -a && . ./.env && set +a   # load BIND_IP and LOG_DIR if .env exists
BIND_IP="${BIND_IP:-127.0.0.1}"
LOG_DIR="${LOG_DIR:-./logs}"

command -v docker >/dev/null || { echo "Docker is not installed" >&2; exit 1; }

# nginx inside the container runs as uid 101, so it must own the log folder
mkdir -p "$LOG_DIR"
if [ "$(id -u)" -eq 0 ]; then chown 101:101 "$LOG_DIR"; else sudo chown 101:101 "$LOG_DIR"; fi

docker compose up -d                   # create or update the container

echo "Waiting for the health check..."
for _ in $(seq 1 20); do
  status="$(docker inspect -f '{{.State.Health.Status}}' secure-web 2>/dev/null || true)"
  [ "$status" = "healthy" ] && break
  sleep 2
done
[ "$status" = "healthy" ] || { echo "Container is not healthy: $status" >&2; docker logs secure-web >&2; exit 1; }

echo "Deployed: http://$BIND_IP:8080/  (logs in $LOG_DIR)"
