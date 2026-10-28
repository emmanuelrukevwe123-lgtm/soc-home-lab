#!/usr/bin/env bash
# Prove the security settings are really in place. Exit code 0 = all checks passed.
# Optional: ADMIN_USER / ADMIN_PASSWORD to also test a successful login.
set -euo pipefail
cd "$(dirname "$0")"
if [ -f .env ]; then set -a; . ./.env; set +a; fi
IP="${BIND_IP:-127.0.0.1}"
HTTPS="https://$IP:8443"
fail=0

result() { if [ "$1" = ok ]; then echo "PASS  $2"; else echo "FAIL  $2"; fail=1; fi; }
# status URL [extra curl options] -> prints the HTTP status code, trusting only our lab CA
status() { local url="$1"; shift; curl -s --cacert tls/ca.crt -o /dev/null -w '%{http_code}' "$@" "$url"; }
expect() { local name="$1" want="$2"; shift 2; local got; got="$(status "$@")"
           if [ "$got" = "$want" ]; then result ok "$name ($got)"; else result no "$name (got $got, want $want)"; fi; }

# --- HTTPS and headers ---
if headers="$(curl -s --cacert tls/ca.crt -I "$HTTPS/")"; then result ok "certificate trusted via lab CA"
else result no "TLS connection failed"; headers=""; fi
for h in Strict-Transport-Security X-Content-Type-Options X-Frame-Options Content-Security-Policy Referrer-Policy; do
  if grep -qi "^$h:" <<<"$headers"; then result ok "header $h"; else result no "header $h missing"; fi
done
if grep -qiE '^server: nginx/[0-9]' <<<"$headers"; then result no "nginx version visible"; else result ok "nginx version hidden"; fi

# --- HTTP behaviour and authentication ---
expect "HTTP redirects to HTTPS"   301 "http://$IP:8080/"
expect "POST blocked"              405 "$HTTPS/" -X POST
expect "admin needs login"         401 "$HTTPS/admin/"
expect "wrong password rejected"   401 "$HTTPS/admin/" -u admin:wrong
if [ -n "${ADMIN_PASSWORD:-}" ]; then
  expect "right password accepted" 200 "$HTTPS/admin/" -u "${ADMIN_USER:-admin}:$ADMIN_PASSWORD"
fi

# --- Container hardening ---
if [ "$(docker inspect -f '{{.HostConfig.ReadonlyRootfs}}' secure-web)" = true ]; then result ok "read-only root filesystem"; else result no "root filesystem writable"; fi
uid="$(docker exec secure-web id -u)"
if [ "$uid" != 0 ]; then result ok "runs as non-root (uid $uid)"; else result no "runs as root"; fi
if docker inspect -f '{{.HostConfig.CapDrop}}' secure-web | grep -q ALL; then result ok "all capabilities dropped"; else result no "capabilities kept"; fi
if docker inspect -f '{{.HostConfig.SecurityOpt}}' secure-web | grep -q no-new-privileges; then result ok "no-new-privileges set"; else result no "no-new-privileges missing"; fi

# --- File permissions on the host ---
mode="$(stat -c %a tls/server.key)"
if [ "$mode" = 600 ]; then result ok "private key mode 600"; else result no "private key mode $mode"; fi

exit "$fail"
