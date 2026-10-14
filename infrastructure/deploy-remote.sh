#!/usr/bin/env bash
set -Eeuo pipefail
IFS=$'\n\t'

APPLICATION='zwanzigeins-game'
DOMAIN='zwanzigeins.baer-software.com'
REPOSITORY='https://github.com/A-Baer/zwanzigeins-game.git'
DEPLOY_PATH='/var/www/zwanzigeins-game'
FLUTTER='/opt/flutter-3.47.4/bin/flutter'
KEEP_RELEASES=3

fail() { printf 'ERROR: %s\n' "$*" >&2; exit 1; }

[[ "${DEPLOY_REVISION:-}" =~ ^[0-9a-f]{40}$ ]] || fail 'DEPLOY_REVISION must be a full lowercase commit SHA.'
[[ "$(id -un)" == deploy ]] || fail 'Run this deployment as the deploy user.'
[[ -x "$FLUTTER" ]] || fail 'Pinned Flutter SDK is missing; run server setup first.'
[[ -d "$DEPLOY_PATH/releases" && -d "$DEPLOY_PATH/.dep" ]] || fail 'Deployment path is not initialized.'

lock_path="$DEPLOY_PATH/.dep/deploy.lock"
mkdir "$lock_path" 2>/dev/null || fail 'Another deployment is running.'
release_path=''
cleanup() {
    exit_status=$?
    if (( exit_status != 0 )) && [[ -n "$release_path" && -d "$release_path" ]]; then
        rm -rf "$release_path"
    fi
    rmdir "$lock_path" 2>/dev/null || true
    exit "$exit_status"
}
trap cleanup EXIT

release_name="$(date -u +'%Y%m%d%H%M%S')-${DEPLOY_REVISION:0:12}"
release_path="$DEPLOY_PATH/releases/$release_name"
[[ ! -e "$release_path" ]] || fail "Release already exists: $release_path"

git clone --quiet --no-checkout "$REPOSITORY" "$release_path"
git -C "$release_path" checkout --quiet --detach "$DEPLOY_REVISION"
[[ "$(git -C "$release_path" rev-parse HEAD)" == "$DEPLOY_REVISION" ]] \
    || fail 'Checked-out revision does not match DEPLOY_REVISION.'

cd "$release_path"
export FLUTTER_SUPPRESS_ANALYTICS=true
export PUB_CACHE="$DEPLOY_PATH/.pub-cache"
"$FLUTTER" pub get --enforce-lockfile
"$FLUTTER" build web --release --pwa-strategy=none
printf '%s\n' "$DEPLOY_REVISION" > "$release_path/REVISION"
printf '%s\n' "$DEPLOY_REVISION" > "$release_path/build/web/REVISION"

previous_target=''
if [[ -L "$DEPLOY_PATH/current" ]]; then
    previous_target=$(readlink "$DEPLOY_PATH/current")
fi
next_target="releases/$release_name/build/web"
ln -s "$next_target" "$DEPLOY_PATH/current.next"
mv -Tf "$DEPLOY_PATH/current.next" "$DEPLOY_PATH/current"

health_ok=0
if [[ -f "/etc/letsencrypt/live/$DOMAIN/fullchain.pem" ]]; then
    curl --fail --silent --show-error --location --max-time 20 \
        --resolve "$DOMAIN:443:127.0.0.1" "https://$DOMAIN/?analytics=off" \
        | grep -q '<title>Zwanzigeins' && health_ok=1
else
    curl --fail --silent --show-error --max-time 20 --header "Host: $DOMAIN" \
        'http://127.0.0.1/?analytics=off' | grep -q '<title>Zwanzigeins' && health_ok=1
fi

if (( health_ok == 0 )); then
    if [[ -n "$previous_target" ]]; then
        ln -s "$previous_target" "$DEPLOY_PATH/current.rollback"
        mv -Tf "$DEPLOY_PATH/current.rollback" "$DEPLOY_PATH/current"
    else
        rm -f "$DEPLOY_PATH/current"
    fi
    fail 'Application health check failed; previous current symlink was restored.'
fi

mapfile -t releases < <(find "$DEPLOY_PATH/releases" -mindepth 1 -maxdepth 1 -type d -printf '%f\n' | sort -r)
for old_release in "${releases[@]:$KEEP_RELEASES}"; do
    [[ "$DEPLOY_PATH/releases/$old_release/build/web" != "$(readlink -f "$DEPLOY_PATH/current")" ]] \
        || fail 'Refusing to remove the active release.'
    rm -rf "$DEPLOY_PATH/releases/$old_release"
done

printf 'Deployed %s to %s\n' "$DEPLOY_REVISION" "$next_target"
