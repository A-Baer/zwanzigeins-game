#!/usr/bin/env bash
set -Eeuo pipefail
IFS=$'\n\t'

DOMAIN='zwanzigeins.baer-software.com'
SERVER_IPV4='165.245.251.172'
CERTBOT_EMAIL='anthony.baer@baer-software.com'
EXISTING_VHOST='/etc/nginx/sites-available/baer-software.com'
TARGET_VHOST="/etc/nginx/sites-available/$DOMAIN"
DEPLOYED_INDEX='/var/www/zwanzigeins-game/current/index.html'

fail() { printf 'ERROR: %s\n' "$*" >&2; exit 1; }

[[ "$EUID" -eq 0 ]] || fail 'Run this script as root.'
[[ -f "$EXISTING_VHOST" ]] || fail 'Existing website virtual host is missing.'
[[ -f "$TARGET_VHOST" ]] || fail 'Run infrastructure/server-setup.sh first.'
[[ -f "$DEPLOYED_INDEX" ]] || fail 'Deploy the first application release before enabling TLS.'
for command_name in certbot curl nginx openssl sha256sum; do
    command -v "$command_name" >/dev/null || fail "Required command is missing: $command_name"
done
systemctl is-active --quiet nginx || fail 'Nginx is not active.'

mapfile -t resolved_ipv4 < <(getent ahostsv4 "$DOMAIN" | awk '{ print $1 }' | sort -u)
printf '%s\n' "${resolved_ipv4[@]}" | grep -qx "$SERVER_IPV4" \
    || fail "$DOMAIN does not resolve to $SERVER_IPV4."
(( ${#resolved_ipv4[@]} == 1 )) || fail "$DOMAIN resolves to unexpected additional IPv4 addresses."

existing_vhost_checksum=$(sha256sum "$EXISTING_VHOST" | awk '{ print $1 }')
existing_vhost_backup=$(mktemp)
cp "$EXISTING_VHOST" "$existing_vhost_backup"
trap 'rm -f "$existing_vhost_backup"' EXIT
certbot --nginx --non-interactive --agree-tos --redirect \
    --email "$CERTBOT_EMAIL" --cert-name "$DOMAIN" -d "$DOMAIN"
if [[ "$(sha256sum "$EXISTING_VHOST" | awk '{ print $1 }')" != "$existing_vhost_checksum" ]]; then
    install -m 0644 -o root -g root "$existing_vhost_backup" "$EXISTING_VHOST"
    nginx -t
    systemctl reload nginx
    fail 'Certbot unexpectedly changed the existing website virtual host; the original file was restored.'
fi

nginx -t
systemctl reload nginx
systemctl is-enabled --quiet certbot.timer || fail 'Certbot renewal timer is not enabled.'
openssl x509 -in "/etc/letsencrypt/live/$DOMAIN/fullchain.pem" -noout -checkend 86400 \
    || fail 'The new certificate is not valid for at least 24 hours.'
openssl x509 -in "/etc/letsencrypt/live/$DOMAIN/fullchain.pem" -noout -ext subjectAltName \
    | grep -q "DNS:$DOMAIN" || fail 'The certificate does not cover the requested domain.'
curl --fail --silent --show-error --location --max-time 20 \
    --resolve "$DOMAIN:443:127.0.0.1" "https://$DOMAIN/?analytics=off" \
    | grep -q '<title>Zwanzigeins' || fail 'HTTPS application health check failed.'
http_status=$(curl --silent --output /dev/null --write-out '%{http_code}' --max-time 15 \
    --resolve "$DOMAIN:80:127.0.0.1" "http://$DOMAIN/?analytics=off")
[[ "$http_status" == 301 || "$http_status" == 308 ]] || fail 'HTTP does not redirect to HTTPS.'

printf 'TLS enabled for %s without modifying %s.\n' "$DOMAIN" "$EXISTING_VHOST"
