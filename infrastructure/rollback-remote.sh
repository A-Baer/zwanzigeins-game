#!/usr/bin/env bash
set -Eeuo pipefail
IFS=$'\n\t'

DOMAIN='zwanzigeins.baer-software.com'
DEPLOY_PATH='/var/www/zwanzigeins-game'

fail() { printf 'ERROR: %s\n' "$*" >&2; exit 1; }
[[ "$(id -un)" == deploy ]] || fail 'Run rollback as the deploy user.'
[[ -L "$DEPLOY_PATH/current" ]] || fail 'No current release exists.'

lock_path="$DEPLOY_PATH/.dep/deploy.lock"
mkdir "$lock_path" 2>/dev/null || fail 'A deployment or rollback is already running.'
trap 'rmdir "$lock_path" 2>/dev/null || true' EXIT

current_real=$(readlink -f "$DEPLOY_PATH/current")
mapfile -t candidates < <(find "$DEPLOY_PATH/releases" -mindepth 3 -maxdepth 3 -type d -path '*/build/web' -print | sort -r)
rollback_target=''
for candidate in "${candidates[@]}"; do
    if [[ "$candidate" != "$current_real" && -f "$candidate/REVISION" ]]; then
        rollback_target="$candidate"
        break
    fi
done
[[ -n "$rollback_target" ]] || fail 'No previous release is available.'

previous_target=$(readlink "$DEPLOY_PATH/current")
relative_target=${rollback_target#"$DEPLOY_PATH/"}
ln -s "$relative_target" "$DEPLOY_PATH/current.rollback"
mv -Tf "$DEPLOY_PATH/current.rollback" "$DEPLOY_PATH/current"

if ! curl --fail --silent --show-error --location --max-time 20 \
    --resolve "$DOMAIN:443:127.0.0.1" "https://$DOMAIN/?analytics=off" \
    | grep -q '<title>Zwanzigeins'; then
    ln -s "$previous_target" "$DEPLOY_PATH/current.restore"
    mv -Tf "$DEPLOY_PATH/current.restore" "$DEPLOY_PATH/current"
    fail 'Rollback health check failed; original release was restored.'
fi

printf 'Rolled back to %s\n' "$(cat "$rollback_target/REVISION")"
