#!/usr/bin/env bash
# DB boundary guard — capricast#911 (estate review 2026-07-18).
#
# ijustus's `DB` binding is Hyperdrive config `ijustus-db`
# (933b84184870481ab097a4506db5a675). Its origin MUST be the OCI Postgres
# `neighbor_aid` database / `neighbor_aid` role. Until 2026-07-18 it was
# misdirected at the kairoscouncil PROD database — an unowned cross-product
# coupling. This check fails hard if that (or any other misdirection) returns.
#
# Requires: CF_ACCOUNT_ID plus CF_HYPERDRIVE_READ_TOKEN or CF_API_TOKEN (the
# token needs the Hyperdrive:Read permission); curl + jq. Read-only: performs
# a single GET against the Cloudflare API.
#
# Modes:
#   default   — a confirmed boundary violation fails; an UNREADABLE config
#               (token lacking Hyperdrive:Read) only warns, so deploys are not
#               blocked by a permissions gap. Used pre-deploy in deploy.yml.
#   STRICT=1  — any inability to verify also fails. Used by the scheduled
#               db-boundary-guard.yml so an unverifiable boundary stays loud.
set -euo pipefail

HYPERDRIVE_ID="933b84184870481ab097a4506db5a675"
EXPECTED_DATABASE="neighbor_aid"
EXPECTED_USER="neighbor_aid"

: "${CF_ACCOUNT_ID:?CF_ACCOUNT_ID is required}"
TOKEN="${CF_HYPERDRIVE_READ_TOKEN:-${CF_API_TOKEN:?CF_HYPERDRIVE_READ_TOKEN or CF_API_TOKEN is required}}"

body=$(mktemp)
status=$(curl -s -o "$body" -w '%{http_code}' \
  -H "Authorization: Bearer ${TOKEN}" \
  "https://api.cloudflare.com/client/v4/accounts/${CF_ACCOUNT_ID}/hyperdrive/configs/${HYPERDRIVE_ID}")

if [ "$status" != "200" ]; then
  msg="Cannot verify DB boundary: Cloudflare API returned HTTP ${status} reading Hyperdrive ${HYPERDRIVE_ID}. The token (CF_HYPERDRIVE_READ_TOKEN, falling back to CF_API_TOKEN) likely lacks the Hyperdrive:Read permission — ops: grant it, or add a dedicated read-only CF_HYPERDRIVE_READ_TOKEN repo secret. See capricast#911."
  if [ "${STRICT:-0}" = "1" ]; then
    echo "::error::${msg}"
    exit 1
  fi
  echo "::warning::${msg}"
  echo "Boundary NOT verified (non-strict mode) — proceeding."
  exit 0
fi

db=$(jq -r '.result.origin.database' "$body")
user=$(jq -r '.result.origin.user' "$body")
host=$(jq -r '.result.origin.host' "$body")

echo "ijustus-db origin: host=${host} database=${db} user=${user}"

if echo "${db} ${user}" | grep -qi 'kairos'; then
  echo "::error::BOUNDARY VIOLATION: ijustus-db Hyperdrive points at a kairoscouncil database again (db=${db} user=${user}). This cross-product coupling was severed 2026-07-18 (capricast#911) and must not return."
  exit 1
fi

if [ "${db}" != "${EXPECTED_DATABASE}" ] || [ "${user}" != "${EXPECTED_USER}" ]; then
  echo "::error::BOUNDARY DRIFT: ijustus-db Hyperdrive origin is db=${db} user=${user}; expected db=${EXPECTED_DATABASE} user=${EXPECTED_USER}. If this change is intentional, update scripts/check-db-boundary.sh and the wrangler.jsonc boundary contract in the same PR."
  exit 1
fi

echo "DB boundary OK: ijustus-db -> ${EXPECTED_DATABASE} (owned)."
