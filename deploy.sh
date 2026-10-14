#!/usr/bin/env bash
set -Eeuo pipefail
IFS=$'\n\t'

DEPLOY_HOST='deploy@165.245.251.172'
REMOTE_SCRIPT='/tmp/zwanzigeins-game-deploy.sh'
LOCAL_SCRIPT='infrastructure/deploy-remote.sh'

fail() { printf 'ERROR: %s\n' "$*" >&2; exit 1; }
cleanup_remote() {
    ssh "$DEPLOY_HOST" "rm -f '$REMOTE_SCRIPT'" >/dev/null 2>&1 || true
}
[[ "${DEPLOY_REVISION:-}" =~ ^[0-9a-f]{40}$ ]] || fail 'Set DEPLOY_REVISION to the full lowercase remote commit SHA.'
[[ -f "$LOCAL_SCRIPT" ]] || fail "Run this command from the repository root."
[[ -z "$(git status --porcelain)" ]] || fail 'The local repository must be clean.'
git cat-file -e "$DEPLOY_REVISION^{commit}" 2>/dev/null || fail 'DEPLOY_REVISION is not available locally.'
[[ "$(git rev-parse HEAD)" == "$DEPLOY_REVISION" ]] || fail 'Local HEAD must equal DEPLOY_REVISION.'
git fetch --quiet origin main
[[ "$(git rev-parse origin/main)" == "$DEPLOY_REVISION" ]] || fail 'origin/main must equal DEPLOY_REVISION.'

local_checksum=$(shasum -a 256 "$LOCAL_SCRIPT" | awk '{ print $1 }')
scp -q "$LOCAL_SCRIPT" "$DEPLOY_HOST:$REMOTE_SCRIPT"
trap cleanup_remote EXIT
remote_checksum=$(ssh "$DEPLOY_HOST" "sha256sum '$REMOTE_SCRIPT'" | awk '{ print $1 }')
[[ "$remote_checksum" == "$local_checksum" ]] || fail 'Remote deployment script checksum mismatch.'
ssh "$DEPLOY_HOST" "chmod 0700 '$REMOTE_SCRIPT' && DEPLOY_REVISION='$DEPLOY_REVISION' '$REMOTE_SCRIPT'"
