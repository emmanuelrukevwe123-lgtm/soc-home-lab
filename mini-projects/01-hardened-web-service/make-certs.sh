#!/usr/bin/env bash
# Create a lab certificate authority (CA) and a server certificate it signs.
set -euo pipefail
cd "$(dirname "$0")"
if [ -f .env ]; then set -a; . ./.env; set +a; fi
BIND_IP="${BIND_IP:-127.0.0.1}"
mkdir -p tls

# 1. The CA: a key pair plus a self-signed certificate that says "I am allowed to sign certificates"
openssl req -x509 -newkey rsa:3072 -nodes -days 365 -sha256 \
  -keyout tls/ca.key -out tls/ca.crt -subj "/CN=Manuel Lab CA" \
  -addext "basicConstraints=critical,CA:TRUE" -addext "keyUsage=critical,keyCertSign,cRLSign"

# 2. The server: a key pair plus a certificate signing request (CSR)
openssl req -newkey rsa:2048 -nodes -keyout tls/server.key -out tls/server.csr -subj "/CN=secure-web.lab"

# 3. The CA signs the CSR. subjectAltName lists the names and IPs the certificate is valid for.
cat > tls/server.ext <<EXT
basicConstraints=CA:FALSE
keyUsage=critical,digitalSignature,keyEncipherment
extendedKeyUsage=serverAuth
subjectAltName=DNS:secure-web.lab,IP:${BIND_IP},IP:127.0.0.1
EXT
openssl x509 -req -in tls/server.csr -CA tls/ca.crt -CAkey tls/ca.key -CAcreateserial \
  -out tls/server.crt -days 90 -sha256 -extfile tls/server.ext

chmod 600 tls/ca.key tls/server.key          # private keys: owner only
openssl verify -CAfile tls/ca.crt tls/server.crt
echo "Created tls/ca.crt (give this to clients) and tls/server.crt + tls/server.key (for nginx)"
