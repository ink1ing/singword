#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT_DIR"

if ! command -v node >/dev/null 2>&1; then
  echo "node is required for refreshing wordbooks"
  exit 1
fi

node scripts/fetch_wordbook_sources.mjs
node scripts/import_wordbooks_from_sources.mjs
node scripts/verify_wordbooks.mjs
node scripts/wordbook_quality_report.mjs

echo "Wordbooks refreshed successfully (including quality report)."
