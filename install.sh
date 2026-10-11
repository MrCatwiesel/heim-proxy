#!/usr/bin/env bash
# Heim-Proxy – Einrichtung IM Container (Debian 12/13).
# Wird von proxmox/create-ct.sh automatisch aufgerufen, kann aber auch allein laufen:
#   bash install.sh
# Erneut ausführen = aktualisieren. Einstellungen und Zertifikate bleiben erhalten.
set -euo pipefail

RAW="https://raw.githubusercontent.com/MrCatwiesel/heim-proxy/main"
DIR=/opt/heim-proxy
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

[[ $EUID -eq 0 ]] || { echo "Bitte als root ausführen."; exit 1; }
say() { printf '\n\033[1;34m==> %s\033[0m\n' "$*"; }

say "Grundpakete und automatische Sicherheits-Updates"
export DEBIAN_FRONTEND=noninteractive
apt-get update -qq
apt-get install -y -qq ca-certificates curl unattended-upgrades >/dev/null
dpkg-reconfigure -f noninteractive unattended-upgrades

if ! command -v docker >/dev/null; then
  say "Docker installieren"
  curl -fsSL https://get.docker.com | sh >/dev/null
fi
docker --version

say "Proxy-Dateien nach $DIR"
mkdir -p "$DIR"
if [[ -f "$HERE/docker-compose.yml" ]]; then
  cp "$HERE/docker-compose.yml" "$DIR/"
  cp "$HERE/update.sh" "$DIR/" 2>/dev/null || true
else
  curl -fsSL "$RAW/docker-compose.yml" -o "$DIR/docker-compose.yml"
  curl -fsSL "$RAW/update.sh" -o "$DIR/update.sh"
fi
chmod +x "$DIR/update.sh" 2>/dev/null || true

say "Proxy starten"
cd "$DIR"
docker compose pull -q
docker compose up -d

say "Warten, bis die Oberfläche bereit ist"
for _ in $(seq 1 60); do
  if curl -fsS -o /dev/null http://127.0.0.1:81; then break; fi
  sleep 2
done

IP=$(hostname -I | awk '{print $1}')
say "Fertig"
cat <<EOF
Verwaltung (nur im Heimnetz):  http://$IP:81
Erste Anmeldung: Konto anlegen, bzw. bei älteren Versionen
  admin@example.com / changeme  → sofort ändern.

Im Router weiterleiten:  TCP 80 → $IP:80   und   TCP 443 → $IP:443
Port 81 NICHT weiterleiten.

Aktualisieren:  $DIR/update.sh
EOF
