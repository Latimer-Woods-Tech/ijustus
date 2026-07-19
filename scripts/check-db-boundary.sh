#!/usr/bin/env bash
# DB boundary guard — capricast#911 (estate review 2026-07-18).
#
# ijustus's `DB` binding is Hyperdrive config `ijustus-db`
# (933b84184870481ab097a4506db5a675). Its origin MUST be the OCI Postgres
# `neighbor_aid` database / `neighbor_aid` role. Until 2026-07-18 it was
# misdirected at the kairoscouncil PROD database — an unowned cross-product
# coupling. This check fails hard if that (or any other misdirection) returns.
#
# Requires: CF_API_TOKEN, CF_ACCOUNT_ID in the environment; curl + jq.
# Read-only: performs a single GET against the Cloudflare API.
set -euo pipefail

HYPERDRIVE_ID="933b84184870481ab097a4506db5a675"
EXPECTED_DATABASE="neighbor_aid"
EXPECTED_USER="neighbor_aid"

: "${CF_API_TOKEN:?CF_API_TOKEN is required}"
: "${CF_ACCOUNT_ID:?CF_ACCOUNT_ID is required}"

cfg=$(curl -sf \
  -H "Authorization: Bearer ${CF_API_TOKEN}" \
  "https://api.cloudflare.com/client/v4/accounts/${CF_ACCOUNT_ID}/hyperdrive/configs/${HYPERDRIVE_ID}")

db=$(echo "$cfg"   | jq -r '.result.origin.database')
user=$(echo "$cfg" | jq -r '.result.origin.user')
host=$(echo "$cfg" | jq -r '.result.origin.host')

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
