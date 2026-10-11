#!/usr/bin/env bash
# Heim-Proxy aktualisieren (im Container ausführen)
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")"
docker compose pull -q
docker compose up -d
docker image prune -f >/dev/null
docker compose ps
