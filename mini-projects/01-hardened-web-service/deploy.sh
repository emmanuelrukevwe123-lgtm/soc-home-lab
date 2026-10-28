#!/usr/bin/env bash
# Deploy the hardened web service. Safe to run again (idempotent).
set -euo pipefail                      # stop on errors, unset variables and failed pipes

cd "$(dirname "$0")"                   # run from this folder wherever it's called from
if [ -f .env ]; then set -a; . ./.env; set +a; fi   # load BIND_IP and LOG_DIR
BIND_IP="${BIND_IP:-127.0.0.1}"
LOG_DIR="${LOG_DIR:-./logs}"

command -v docker >/dev/null || { echo "Docker is not installed" >&2; exit 1; }
[ -f tls/server.crt ] || ./make-certs.sh
[ -f auth/.htpasswd ] || { echo "Run ./make-user.sh first to create the admin login" >&2; exit 1; }

# nginx inside the container runs as uid 101, so it must own its logs, key and password file
SUDO=""; [ "$(id -u)" -eq 0 ] || SUDO="sudo"
mkdir -p "$LOG_DIR"
$SUDO chown 101:101 "$LOG_DIR" tls/server.key auth/.htpasswd

docker compose up -d                   # create or update the container

echo "Waiting for the health check..."
status="starting"
for _ in $(seq 1 20); do
  status="$(docker inspect -f '{{.State.Health.Status}}' secure-web 2>/dev/null || true)"
  [ "$status" = "healthy" ] && break
  sleep 2
done
[ "$status" = "healthy" ] || { echo "Container is not healthy: $status" >&2; docker logs secure-web >&2; exit 1; }

echo "Deployed: https://$BIND_IP:8443/  (HTTP 8080 redirects; logs in $LOG_DIR)"
