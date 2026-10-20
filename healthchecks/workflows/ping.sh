#!/usr/bin/env bash
# Ping a Healthchecks.io check: ping.sh <suffix>, where suffix is "", "/start" or "/fail".
# Reads URL and RUN_ID/RUN_URL from the environment. The run ID becomes the
# ping's rid (zero-padded into UUID form, as Healthchecks requires a UUID), so
# start and finish pings of the same workflow run are paired.
set -euo pipefail

suffix="$1"
base="${URL%%\?*}"
query="${URL#"$base"}"
query="${query#\?}"

digits=$(printf '%032d' "$RUN_ID")
rid="${digits:0:8}-${digits:8:4}-${digits:12:4}-${digits:16:4}-${digits:20:12}"

curl -sS --fail-with-body -m 10 --retry 5 --data-raw "$RUN_URL" \
  "${base%/}${suffix}?rid=${rid}${query:+&$query}"
echo
