#!/usr/bin/env bash
# Prove the security settings are really in place. Exit code 0 = all checks passed.
set -euo pipefail
cd "$(dirname "$0")"
[ -f .env ] && set -a && . ./.env && set +a
URL="http://${BIND_IP:-127.0.0.1}:8080"
fail=0

pass() { echo "PASS  $1"; }
bad()  { echo "FAIL  $1"; fail=1; }

headers="$(curl -sI "$URL/")"
for h in X-Content-Type-Options X-Frame-Options Content-Security-Policy Referrer-Policy; do
  grep -qi "^$h:" <<<"$headers" && pass "header $h" || bad "header $h missing"
done
grep -qiE '^server: nginx/[0-9]' <<<"$headers" && bad "nginx version is visible" || pass "nginx version hidden"

code="$(curl -s -o /dev/null -w '%{http_code}' -X POST "$URL/")"
[ "$code" = "405" ] && pass "POST blocked (405)" || bad "POST returned $code"

[ "$(docker inspect -f '{{.HostConfig.ReadonlyRootfs}}' secure-web)" = "true" ] && pass "read-only root filesystem" || bad "root filesystem is writable"
[ "$(docker exec secure-web id -u)" != "0" ] && pass "runs as non-root (uid $(docker exec secure-web id -u))" || bad "runs as root"
grep -q ALL <<<"$(docker inspect -f '{{.HostConfig.CapDrop}}' secure-web)" && pass "all capabilities dropped" || bad "capabilities not dropped"
grep -q no-new-privileges <<<"$(docker inspect -f '{{.HostConfig.SecurityOpt}}' secure-web)" && pass "no-new-privileges set" || bad "no-new-privileges missing"

exit "$fail"
