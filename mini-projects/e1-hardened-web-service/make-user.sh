#!/usr/bin/env bash
# Create the admin login. The password is stored only as a salted SHA-512 hash.
set -euo pipefail
cd "$(dirname "$0")"
user="${ADMIN_USER:-admin}"
if [ -n "${ADMIN_PASSWORD:-}" ]; then
  pw="$ADMIN_PASSWORD"                        # non-interactive (used by CI)
else
  read -rsp "New password for $user: " pw; echo
fi
mkdir -p auth
printf '%s:%s\n' "$user" "$(printf '%s' "$pw" | openssl passwd -6 -stdin)" > auth/.htpasswd
chmod 600 auth/.htpasswd
echo "Saved auth/.htpasswd for user '$user':"
cut -d: -f2 auth/.htpasswd | cut -c1-20; echo "...  (\$6\$ = SHA-512 crypt, then the salt, then the hash)"
