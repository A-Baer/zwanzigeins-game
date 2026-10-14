#!/usr/bin/env bash
set -Eeuo pipefail
IFS=$'\n\t'

APPLICATION='zwanzigeins-game'
DOMAIN='zwanzigeins.baer-software.com'
DEPLOY_USER='deploy'
DEPLOY_PATH='/var/www/zwanzigeins-game'
FLUTTER_VERSION='3.47.4'
FLUTTER_ARCHIVE='flutter_linux_3.47.4-stable.tar.xz'
FLUTTER_URL="https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/$FLUTTER_ARCHIVE"
FLUTTER_SHA256='5b45f0ceda99b9bebdc873e7e69f6450aeb4c30f454b505e2e62fc9255a907d3'
FLUTTER_PATH="/opt/flutter-$FLUTTER_VERSION"
NGINX_AVAILABLE="/etc/nginx/sites-available/$DOMAIN"
NGINX_ENABLED="/etc/nginx/sites-enabled/$DOMAIN"

log() { printf '\n[%s] %s\n' "$(date -u +'%Y-%m-%dT%H:%M:%SZ')" "$*"; }
fail() { printf 'ERROR: %s\n' "$*" >&2; exit 1; }

[[ "$EUID" -eq 0 ]] || fail 'Run this script as root.'
. /etc/os-release
[[ "${ID:-}" == ubuntu && "${VERSION_ID:-}" == 24.04 ]] || fail 'Only Ubuntu 24.04 LTS is supported.'
[[ "$(dpkg --print-architecture)" == amd64 ]] || fail 'Only amd64 is supported.'
id "$DEPLOY_USER" >/dev/null 2>&1 || fail "Required deployment user does not exist: $DEPLOY_USER"
DEPLOY_HOME=$(getent passwd "$DEPLOY_USER" | cut -d: -f6)
[[ -n "$DEPLOY_HOME" && -d "$DEPLOY_HOME" ]] || fail "Deployment user has no usable home directory: $DEPLOY_USER"
for command_name in curl git nginx sha256sum tar xz; do
    command -v "$command_name" >/dev/null || fail "Required command is missing: $command_name"
done
systemctl is-active --quiet nginx || fail 'Nginx must already be active.'

log 'Verifying shared-server capacity and existing swap'
free_mib=$(df --output=avail -BM / | tail -1 | tr -dc '0-9')
(( free_mib >= 4096 )) || fail 'At least 4 GiB free disk space is required before installing Flutter.'
mapfile -t active_swap_targets < <(swapon --noheadings --show=NAME)
(( ${#active_swap_targets[@]} > 0 )) || fail 'An active swap target is required on this 1 GiB build server.'
for active_swap_target in "${active_swap_targets[@]}"; do
    active_swap_uuid=$(blkid -s UUID -o value "$active_swap_target" 2>/dev/null || true)
    active_swap_unit=$(systemd-escape --path --suffix=swap "$active_swap_target")
    if ! awk -v source="$active_swap_target" '$1 == source && $3 == "swap" { found=1 } END { exit !found }' /etc/fstab \
        && { [[ -z "$active_swap_uuid" ]] || ! awk -v source="UUID=$active_swap_uuid" '$1 == source && $3 == "swap" { found=1 } END { exit !found }' /etc/fstab; } \
        && ! systemctl is-enabled --quiet "$active_swap_unit"; then
        fail "Active swap has no persistent fstab entry or enabled systemd unit: $active_swap_target"
    fi
done

log "Installing checksum-pinned Flutter $FLUTTER_VERSION"
if [[ ! -x "$FLUTTER_PATH/bin/flutter" ]]; then
    [[ ! -e "$FLUTTER_PATH" ]] || fail "Incomplete Flutter installation exists: $FLUTTER_PATH"
    flutter_temp=$(mktemp -d)
    trap 'rm -rf "$flutter_temp"' EXIT
    curl --fail --silent --show-error --location "$FLUTTER_URL" --output "$flutter_temp/$FLUTTER_ARCHIVE"
    printf '%s  %s\n' "$FLUTTER_SHA256" "$flutter_temp/$FLUTTER_ARCHIVE" | sha256sum --check --status \
        || fail 'Flutter archive checksum mismatch.'
    tar -xJf "$flutter_temp/$FLUTTER_ARCHIVE" -C "$flutter_temp"
    mv "$flutter_temp/flutter" "$FLUTTER_PATH"
    chown -R "$DEPLOY_USER:$DEPLOY_USER" "$FLUTTER_PATH"
    trap - EXIT
    rm -rf "$flutter_temp"
fi
[[ "$(stat -c '%U:%G' "$FLUTTER_PATH")" == "$DEPLOY_USER:$DEPLOY_USER" ]] \
    || fail "Flutter SDK must be owned by $DEPLOY_USER."
(
    cd "$DEPLOY_HOME"
    runuser -u "$DEPLOY_USER" -- env -u ANDROID_HOME -u ANDROID_SDK_ROOT \
        HOME="$DEPLOY_HOME" USER="$DEPLOY_USER" LOGNAME="$DEPLOY_USER" \
        FLUTTER_SUPPRESS_ANALYTICS=true \
        "$FLUTTER_PATH/bin/flutter" precache --web
)
installed_flutter_version=$(
    cd "$DEPLOY_HOME"
    runuser -u "$DEPLOY_USER" -- env -u ANDROID_HOME -u ANDROID_SDK_ROOT \
        HOME="$DEPLOY_HOME" USER="$DEPLOY_USER" LOGNAME="$DEPLOY_USER" \
        FLUTTER_SUPPRESS_ANALYTICS=true \
        "$FLUTTER_PATH/bin/flutter" --version --machine \
        | sed -n 's/.*"frameworkVersion"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p'
)
[[ "$installed_flutter_version" == "$FLUTTER_VERSION" ]] \
    || fail 'Installed Flutter version does not match the pinned version.'

log 'Creating an isolated static deployment path'
install -d -m 0755 -o "$DEPLOY_USER" -g "$DEPLOY_USER" "$DEPLOY_PATH"
install -d -m 0755 -o "$DEPLOY_USER" -g "$DEPLOY_USER" "$DEPLOY_PATH/.dep" "$DEPLOY_PATH/releases"
if [[ -e "$DEPLOY_PATH/current" && ! -L "$DEPLOY_PATH/current" ]]; then
    fail 'Current deployment path exists but is not a symlink.'
fi

log 'Installing the isolated HTTP virtual host'
nginx_temp=$(mktemp)
cat > "$nginx_temp" <<NGINX
# Managed by zwanzigeins-game infrastructure/server-setup.sh.
server {
    listen 80;
    listen [::]:80;
    server_name $DOMAIN;

    root $DEPLOY_PATH/current;
    index index.html;

    location = /index.html {
        add_header Cache-Control "no-cache, no-store, must-revalidate" always;
        try_files \$uri =404;
    }

    location = /flutter_bootstrap.js {
        add_header Cache-Control "no-cache, no-store, must-revalidate" always;
        try_files \$uri =404;
    }

    location / {
        try_files \$uri \$uri/ /index.html;
    }

    location ~ /\. { deny all; }
}
NGINX
if [[ -f "$NGINX_AVAILABLE" ]] && grep -q '# managed by Certbot' "$NGINX_AVAILABLE"; then
    grep -q "server_name $DOMAIN;" "$NGINX_AVAILABLE" \
        || fail 'Existing TLS virtual host has an unexpected server name.'
    grep -q "root $DEPLOY_PATH/current;" "$NGINX_AVAILABLE" \
        || fail 'Existing TLS virtual host has an unexpected document root.'
else
    install -m 0644 -o root -g root "$nginx_temp" "$NGINX_AVAILABLE"
fi
rm -f "$nginx_temp"
ln -sfn "$NGINX_AVAILABLE" "$NGINX_ENABLED"
nginx -t
systemctl reload nginx

log 'Verifying isolation from the existing website virtual host'
nginx -T 2>/dev/null | grep -q "server_name baer-software.com www.baer-software.com dashboard.baer-software.com;" \
    || fail 'Existing website virtual host is no longer present.'
nginx -T 2>/dev/null | grep -q "server_name $DOMAIN;" \
    || fail 'Zwanzigeins virtual host is not active.'
curl --silent --show-error --output /dev/null --write-out '%{http_code}' \
    --header "Host: $DOMAIN" http://127.0.0.1/ | grep -Eq '^(200|404)$' \
    || fail 'The isolated HTTP virtual host is not reachable.'

log 'Server setup completed without changing DNS or TLS'
