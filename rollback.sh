#!/usr/bin/env bash
set -Eeuo pipefail
IFS=$'\n\t'

DEPLOY_HOST='deploy@165.245.251.172'
REMOTE_SCRIPT='/tmp/zwanzigeins-game-rollback.sh'
LOCAL_SCRIPT='infrastructure/rollback-remote.sh'

fail() { printf 'ERROR: %s\n' "$*" >&2; exit 1; }
cleanup_remote() {
    ssh "$DEPLOY_HOST" "rm -f '$REMOTE_SCRIPT'" >/dev/null 2>&1 || true
}
[[ -f "$LOCAL_SCRIPT" ]] || fail 'Run this command from the repository root.'
[[ -z "$(git status --porcelain)" ]] || fail 'The local repository must be clean.'

local_checksum=$(shasum -a 256 "$LOCAL_SCRIPT" | awk '{ print $1 }')
scp -q "$LOCAL_SCRIPT" "$DEPLOY_HOST:$REMOTE_SCRIPT"
trap cleanup_remote EXIT
remote_checksum=$(ssh "$DEPLOY_HOST" "sha256sum '$REMOTE_SCRIPT'" | awk '{ print $1 }')
[[ "$remote_checksum" == "$local_checksum" ]] || fail 'Remote rollback script checksum mismatch.'
ssh "$DEPLOY_HOST" "chmod 0700 '$REMOTE_SCRIPT' && '$REMOTE_SCRIPT'"
