#!/usr/bin/env bash
# Send a Pushover notification about this workflow run: send.sh success|failed.
# Reads API_KEY and USER_KEY from the environment.
set -euo pipefail

case "$1" in
  success)
    title="🟢 $GITHUB_REPOSITORY deployed ($GITHUB_REF_NAME)"
    message="$GITHUB_REPOSITORY deployed from $GITHUB_REF_NAME (${GITHUB_SHA::7})"
    priority=0
    ;;
  failed)
    title="🔴 $GITHUB_REPOSITORY deploy FAILED ($GITHUB_REF_NAME)"
    message="Build or deploy of $GITHUB_REPOSITORY from $GITHUB_REF_NAME failed (${GITHUB_SHA::7})"
    priority=1
    ;;
  *)
    echo "Unknown status '$1'" >&2
    exit 1
    ;;
esac

curl -sS --fail-with-body -m 10 --retry 3 \
  --form-string "token=$API_KEY" \
  --form-string "user=$USER_KEY" \
  --form-string "title=$title" \
  --form-string "message=$message" \
  --form-string "priority=$priority" \
  --form-string "url=$GITHUB_SERVER_URL/$GITHUB_REPOSITORY/actions/runs/$GITHUB_RUN_ID" \
  --form-string "url_title=View workflow run" \
  https://api.pushover.net/1/messages.json
echo
